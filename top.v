module top(
    input RSTN,
    input [3:0] BTN_y,
    input [15:0] SW,
    input clk_100mhz,

    output [4:0] BTN_x,
    output CR,
    output RDY,
    output readn,
    output seg_clk,
    output seg_sout,
    output SEG_PEN,
    output seg_clrn,
    output led_clk,
    output led_sout,
    output LED_PEN,
    output led_clrn,
    output [3:0] VGA_R,VGA_G,VGA_B,
    output  HSYNC, VSYNC					
    );

    wire rst;
    wire [4:0] Key_out;
    wire [3:0] pulse_out;
    wire [3:0] BTN_OK;
    wire [15:0] SW_OK;

    wire [31:0] Div;
    wire Clk_CPU;
    
    wire [31:0] Ai;
    wire [31:0] Bi;
    wire [7:0] blink;

    wire [31:0] Disp_num;
    wire [7:0] point_out;
    wire [7:0] LE_out;

    wire empty;

    wire [31:0] instr;
    wire [31:0] Data_in;
    wire mem_w;
    wire [31:0] PC;
    wire [31:0] Addr_out;
    wire [31:0] Data_out;
    wire INT;

    wire [31:0] ram_data_out;
    wire [15:0] LED_out;
    wire [31:0] counter_out;
    wire counter1_out;
    wire counter2_out;
    wire [31:0] ram_data_in;
    wire [9:0] ram_addr;
    wire data_ram_we;
    wire GPIOF0,GPIOE0;
    wire counter_we;
    wire [31:0] CPU2IO;
    wire IO_clk;

    wire [1:0] counter_set;
    wire [3:0]  swlength;

    wire [8:0] row;
    wire [9:0] col;
    wire [12:0] VRAMA;
    wire rdn;
    wire [11:0] Pixel;
    wire [11:0] VGAData;

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    SAnti_jitter U9 (.clk(clk_100mhz),
                     .RSTN(RSTN),
                     .readn(readn),
                     .Key_y(BTN_y),
                     .Key_x(BTN_x),
                     .SW(SW),
                     .Key_out(Key_out),
                     .Key_ready(RDY),
                     .pulse_out(pulse_out),
                     .BTN_OK(BTN_OK),
                     .SW_OK(SW_OK),
                     .CR(CR),
                     .rst(rst));

    clk_div U8(.clk(clk_100mhz),
               .rst(rst),
               .SW2(SW_OK[2]),
               .clkdiv(Div),
               .Clk_CPU(Clk_CPU));

    SEnter_2_32 M4(.clk(clk_100mhz),
                   .BTN(BTN_OK[2:0]),
                   .Ctrl({SW_OK[7:5],SW_OK[15],SW_OK[0]}),
                   .D_ready(RDY),
                   .Din(Key_out),
                   .readn(readn),
                   .Ai(Ai),
                   .Bi(Bi),
                   .blink(blink));

    SSeg7_Dev U6(.clk(clk_100mhz),
                 .rst(rst),
                 .Start(Div[20]),
                 .SW0(SW_OK[0]),
                 .flash(Div[25]),
                 .Hexs(Disp_num),
                 .point(point_out),
                 .LES(LE_out),
                 .seg_clk(seg_clk),
                 .seg_sout(seg_sout),
                 .SEG_PEN(SEG_PEN),
                 .seg_clrn(seg_clrn));

    PCPU U1(.clk(Clk_CPU),
            .reset(rst),
            .MIO_ready(),
            .inst_in(instr),
            .Data_in(Data_in),
            .mem_w(mem_w),
            .PC_out(PC),
            .Addr_out(Addr_out),
            .Data_out(Data_out),
            .CPU_MIO(),
            .INT(INT),
            .swlength(swlength));

    MIO_BUS U4(.clk(clk_100mhz),
               .rst(rst),
               .BTN(BTN_OK),
               .SW(SW_OK),
               .mem_w(mem_w),
               .Cpu_data2bus(Data_out),
               .addr_bus(Addr_out),
               .ram_data_out(ram_data_out),
               .led_out(LED_out),
               .counter_out(counter_out),
               .counter0_out(INT),
               .counter1_out(counter1_out),
               .counter2_out(counter2_out),
               .Cpu_data4bus(Data_in),
               .ram_data_in(ram_data_in),
               .ram_addr(ram_addr),
               .data_ram_we(data_ram_we),
               .GPIOf0000000_we(GPIOF0),
               .GPIOe0000000_we(GPIOE0),
               .counter_we(counter_we),
               .Peripheral_in(CPU2IO));

    assign IO_clk=~Clk_CPU;

    Multi_8CH32 U5(.clk(IO_clk),
                   .rst(rst),
                   .EN(GPIOE0),
                   .Test(SW_OK[7:5]),
                   .point_in({Div[31:0],Div[31:0]}),
                   .LES(64'b0),
                   .Data0(CPU2IO),
                   .data1({1'b0,1'b0,PC[31:2]}),
                   .data2(instr[31:0]),
                   .data3(counter_out[31:0]),
                   .data4(Addr_out[31:0]),
                   .data5(Data_out[31:0]),
                   .data6(Data_in[31:0]),
                   .data7(PC[31:0]),
                   .point_out(point_out[7:0]),
                   .LE_out(LE_out),
                   .Disp_num(Disp_num));

    SPIO U7(.clk(IO_clk),
            .rst(rst),
            .Start(Div[20]),
            .EN(GPIOF0),
            .P_Data(CPU2IO),
            .counter_set(counter_set),
            .LED_out(LED_out),
            .led_clk(led_clk),
            .led_sout(led_sout),
            .led_clrn(led_clrn),
            .LED_PEN(LED_PEN),
            .GPIOf0());

    ROM_D U2(.a(PC[11:2]),
             .spo(instr));

    RAM_B U3(.addra(ram_addr),
             .wea(swlength),
             .dina(ram_data_in),
             .clka(~clk_100mhz),
             .douta(ram_data_out));

    Counter_x U10(.clk(IO_clk),
                  .rst(rst),
                  .clk0(Div[6]),
                  .clk1(Div[9]),
                  .clk2(Div[11]),
                  .counter_we(counter_we),
                  .counter_val(CPU2IO),
                  .counter_ch(counter_set),
                  .counter0_OUT(INT),
                  .counter1_OUT(counter1_out),
                  .counter2_OUT(counter2_out),
                  .counter_out(counter_out));

    
   assign Pixel = (row<=220||row>=420)? 12'b111100001111:Data_out[11:0];
    
    
    VGAIO U11(.clk(Clk_CPU),
              .rst(rst),
              .VRAMOUT(Data_out[15:0]),
              .Pixel({SW_OK[15],Pixel}),
              .Test(14'b0),
              .Din({16'b0,SW_OK}),
              .Regaddr(),
              .Cursor(13'b0000110000011),
              .Blink(blink),
              .row(row),
              .col(col),
              .R(VGA_R),.G(VGA_G),.B(VGA_B),
              .HSYNC(HSYNC),.VSYNC(VSYNC),
              .VRAMA(VRAMA),
              .rdn(rdn));



endmodule
