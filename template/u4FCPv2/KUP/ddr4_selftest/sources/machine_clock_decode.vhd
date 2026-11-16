LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

Entity machine_clock_decode is      
  port(
    clk_i             : in std_logic;  -- sync clock 64M   
    rst_i             : in std_logic;
    serial_data_i     : in std_logic;

    pps_update_o      : out std_logic;
    seconds_o         : out std_logic_vector(15 downto 0);   

    bunchid_update_o  : out std_logic;
    bunchid_o         : out std_logic_vector(47 downto 0)
  );
end machine_clock_decode;  

Architecture beha of machine_clock_decode is
  --===========================================================================
  --                         signal declaration
  --===========================================================================
  constant IDLE_LEN  : integer := 12;

  type t_state is (MCE_IDLE,MCE_B0,MCE_B1,MCE_B2,MCE_B3,MCE_B4,MCE_CHECK,MCE_E);
  signal state: t_state; 

  signal sin_vector           : std_logic_vector(13 downto 0);  
  signal sin_count            : std_logic_vector(3 downto 0);  
  signal rc_temp              : std_logic_vector(7 downto 0);  
  signal mc_temp              : std_logic_vector(7 downto 0);  
  signal type_r               : std_logic_vector(3 downto 0);  
  signal data_h               : std_logic_vector(7 downto 0);  
  signal data_l               : std_logic_vector(7 downto 0);  
  signal bunchid_temp         : std_logic_vector(47 downto 0);  
  signal seconds_temp         : std_logic_vector(15 downto 0);    
  signal bunchid_local        : std_logic_vector(47 downto 0);       

  signal machine_clock_count  : std_logic_vector(19 downto 0);  

begin

  p_fsm : process(clk_i,rst_i) 
  begin
    if(rst_i = '1')then
      sin_vector            <= (OTHERS => '0');
      sin_count             <= (OTHERS => '0');
      machine_clock_count   <= (OTHERS => '0');
      rc_temp               <= (OTHERS => '0');
      mc_temp               <= (OTHERS => '0');
      type_r                <= (OTHERS => '0');
      data_h                <= (OTHERS => '0');
      data_l                <= (OTHERS => '0');
      bunchid_temp          <= (OTHERS => '0');
      seconds_temp          <= (OTHERS => '0');
      seconds_o             <= (OTHERS => '0');
      bunchid_o             <= (OTHERS => '0');
      pps_update_o          <= '0';
      bunchid_update_o      <= '0';
      state                 <= MCE_IDLE;  
      
    elsif rising_edge(clk_i) then
      sin_vector        <= sin_vector(sin_vector'HIGH -1 downto 0) & serial_data_i;
      pps_update_o      <= '0';
      bunchid_update_o  <= '0';
      
      case state is
        when MCE_IDLE =>
          if (sin_vector = "00000000000001" and serial_data_i='0') then
            state       <= MCE_B0;     
          else
            state       <= MCE_IDLE;                          
          end if; 
          sin_count     <= (OTHERS => '0');
          rc_temp       <= (OTHERS => '0');
          mc_temp       <= (OTHERS => '0');
          type_r        <= (OTHERS => '0');
          data_h        <= (OTHERS => '0');
          data_l        <= (OTHERS => '0');

        when MCE_B0 =>
          if sin_count = X"8" then
            if serial_data_i = '1' then
              state <= MCE_B1;    
              rc_temp <= sin_vector(7 downto 0);
            else
              state <= MCE_IDLE;    
            end if;
            sin_count <= (OTHERS => '0');
          else
            state <= MCE_B0;   
            sin_count <= sin_count + '1';                           
          end if; 

        when MCE_B1 =>
          if sin_count = X"8" then
            if serial_data_i = '1' then
              state <= MCE_B2;    
              mc_temp <= sin_vector(7 downto 0);
            else
              state <= MCE_IDLE;    
            end if;
            sin_count <= (OTHERS => '0');
          else
            state <= MCE_B1;   
            sin_count <= sin_count + '1';                           
          end if; 

        when MCE_B2 =>
          if sin_count = X"8" then
            if serial_data_i = '1' then
              state <= MCE_B3;    
              type_r <= sin_vector(3 downto 0);
            else
              state <= MCE_IDLE;    
            end if;
            sin_count <= (OTHERS => '0');
          else
            state <= MCE_B2;   
            sin_count <= sin_count + '1';                           
          end if;

        when MCE_B3 =>
          if sin_count = X"8" then
            if serial_data_i = '1' then
              state <= MCE_B4;    
              data_h <= sin_vector(7 downto 0);
            else
              state <= MCE_IDLE;    
            end if;
            sin_count <= (OTHERS => '0');
          else
            state <= MCE_B3;   
            sin_count <= sin_count + '1';                           
          end if;

        when MCE_B4 =>
          if sin_count = X"8" then
            if serial_data_i = '1' then
              state <= MCE_CHECK;    
              data_l <= sin_vector(7 downto 0);
            else
              state <= MCE_IDLE;    
            end if;
            sin_count <= (OTHERS => '0');
          else
            state <= MCE_B4;   
            sin_count <= sin_count + '1';                           
          end if;  

        when MCE_CHECK =>
          state <= MCE_E;
          if(type_r = X"1")then
            machine_clock_count <= X"00001";
          else
            machine_clock_count <= machine_clock_count + X"00001";
          end if;
          case type_r is
            when X"1" => 
              seconds_temp <= data_h & data_l; 
            when X"2" => 
              bunchid_temp(15 downto 0) <= data_h & data_l; 
            when X"4" => 
              bunchid_temp(31 downto 16) <= data_h & data_l; 
            when X"8" => 
              bunchid_temp(47 downto 32) <= data_h & data_l;
            when others => NULL;
          end case;

        when MCE_E =>
          if serial_data_i = '1' then
            -- The bunchid is 0 when the clock is out of 
            -- sync or the bunchid function is turned off
            if(bunchid_temp = X"000000000000")then
              bunchid_update_o      <= '0';
              bunchid_o             <= X"000000000000" ;
            else
              bunchid_update_o    <= '1';
              
              if(type_r=X"8") then
              -- Compensate for the delay introduced by encoding and decoding
                bunchid_o           <= bunchid_temp + X"000000000003";
                bunchid_local       <= bunchid_temp + X"000000000004";
              else 
                bunchid_o     <= bunchid_local;      
                bunchid_local <= bunchid_local + X"000000000001";
              end if;
            end if;
            if(machine_clock_count = 1000000)then
              pps_update_o        <= '1';
              seconds_o           <= seconds_temp+X"0001";
              machine_clock_count <= (others => '0');
            end if;
          end if;
          sin_count               <= (others => '0');
          state                   <= MCE_IDLE;

        when others => 
          state                   <= MCE_IDLE;

      end case;          
        
    end if;
  end process;   
   
   

    
end beha;