module Train(
    //Input Port
    clk,
    rst_n,
	in_valid,
	data,

    //Output Port
    out_valid,
	result
);

input        clk;
input 	     in_valid;
input        rst_n;
input  [3:0] data;
output   reg out_valid;
output   reg result; 

//--------------------reg/wire declaration-----------------------//

parameter IDLE  = 'd0;
parameter INPUT = 'd1;
parameter PUT_IN  = 'd2;
parameter TAKE_OUT = 'd3;
parameter COMP  = 'd4;
parameter OUTPUT= 'd5;

reg [2:0] curr_state, next_state;

//INPUT
reg [3:0] num_carriage;
reg [3:0] order[0:15];
integer i, j;

//CALC
reg [3:0] ptr, ptr_comb;
reg [3:0] cnt_num;
reg [3:0] queue[0:15];
reg [3:0] queue_comb[0:15];
reg [3:0] queue_ptr, queue_ptr_comb;
reg false_result, false_result_comb;
reg true_result, true_result_comb;
reg [3:0] thrown, thrown_comb, thrown_d1;


//OUTPUT
reg out_valid_comb, result_comb;

wire smaller = thrown<cnt_num;


//-------------------FSM-------------------------------//

reg [3:0] cnt_state;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_state <= 'd0;
    else if(curr_state!=next_state) cnt_state <= 'd0;
    else    cnt_state <= cnt_state + 'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  curr_state <= IDLE;
    else        curr_state <= next_state;
end
always @(*) begin
    case(curr_state)
        IDLE: begin
            if(in_valid)    next_state = INPUT;
            else            next_state = IDLE;
        end
        INPUT: begin
            if(!in_valid)   next_state = PUT_IN;
            else            next_state = INPUT;
        end
        PUT_IN: begin
            if(cnt_num==order[ptr]) next_state = TAKE_OUT;
            else                    next_state = PUT_IN;
        end
        TAKE_OUT: begin
            //if(!ptr)    next_state = OUTPUT;
            ////else if(thrown==order[ptr+'d1]) next_state = PUT_IN; // && cnt_state
            //else if(!queue_ptr) next_state = PUT_IN; // || thrown<cnt_num // || order[ptr]>thrown
            //else if(false_result)   next_state = OUTPUT;
            //else        next_state = TAKE_OUT;
            if(queue[0]!=order[ptr] || queue[0]==0)    next_state = COMP;
            else                        next_state = TAKE_OUT;
        end
        COMP: begin
            if(true_result_comb || false_result_comb) next_state = OUTPUT;
            else if(queue[0] < order[ptr])   next_state = PUT_IN;
            else    next_state = COMP;
        end
        OUTPUT: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

//-------------------INPUT-------------------------------//

//num_carriage
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  num_carriage <= 'd0;
    else begin
        if(in_valid && curr_state==IDLE)    num_carriage <= data;
        else                                num_carriage <= num_carriage;
    end
end
//order
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<16; i=i+1) begin
            order[i] <= 'd0;
        end
    end
    else begin
        if(curr_state==INPUT && in_valid) begin
            order[0] <= data;
            for(j=0; j<16; j=j+1) begin
                order[j+1] <= order[j];
            end
        end
        else if(curr_state==IDLE) begin
            for(i=0; i<16; i=i+1) begin
                order[i] <= 'd0;
            end
        end
    end
end

//-------------------CALC-------------------------------//

//ptr_order
reg [3:0] ptr_order;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  ptr_order <= 'd0;
    else begin
        if(curr_state==INPUT)   ptr_order <= num_carriage - 'd1;
        else if(ptr_order=='d0) ptr_order <= 'd0;
        else                    ptr_order <= ptr_order - 'd1;
    end
end


//ptr -> input order place 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  ptr <= 'd0;
    else begin
        ptr <= ptr_comb;
    end
end
//cnt_num
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_num <= 'd0;
    else begin
        if(curr_state==PUT_IN)  cnt_num <= cnt_num + 'd1;
        else if(curr_state==TAKE_OUT || curr_state==COMP)   cnt_num <= cnt_num;
        else                    cnt_num <= 'd1;
    end
end
//queue
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<16; i=i+1) begin
            queue[i] <= 'd0;
        end
    end
    else begin
        for(j=0; j<16; j=j+1) begin
            queue[j] <= queue_comb[j];
        end
    end
end
//queue_ptr
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  queue_ptr <= 'd0;
    else        queue_ptr <= queue_ptr_comb;
end

always @(*) begin
    for(i=0;i<16;i=i+1) queue_comb[i] = queue[i];
    queue_ptr_comb = queue_ptr;
    ptr_comb = ptr;
    thrown_comb = 'd0;
    true_result_comb = true_result;
    false_result_comb = false_result;

    case(curr_state)
        IDLE: begin
            for(i=0;i<16;i=i+1) queue_comb[i] = 'd0;
            queue_ptr_comb = 'd0;
            true_result_comb = 'd0;
            false_result_comb = 'd0;
        end
        INPUT: begin
            ptr_comb = num_carriage - 'd1;;
        end
        PUT_IN: begin
            if(cnt_num <= order[ptr]) begin
                queue_comb[0] = cnt_num;
                for(i=0;i<16;i=i+1) queue_comb[i+1] = queue[i];
                queue_ptr_comb = queue_ptr + 'd1;
            end
        end
        TAKE_OUT: begin
            if(queue[0]==order[ptr]) begin
                for(i=0;i<15;i=i+1) queue_comb[i] = queue[i+1];
                queue_comb[15] = 'd0;
                if(ptr!=0)  ptr_comb = ptr - 'd1;
                queue_ptr_comb = queue_ptr - 'd1;
                thrown_comb = queue[0];
            end
        end
        COMP: begin
            if(ptr==0)  true_result_comb = 1;
            if(thrown_d1 > order[ptr]+'d1)  false_result_comb = 1;
            
        end
        default: begin

        end
    endcase
end
//false_result
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  false_result <= 1'b0;
    else begin
        //if(curr_state==TAKE_OUT && queue[0]!=order[ptr] && ptr)    false_result <= 1'b1;
        ////else if()
        //else if(curr_state==IDLE || curr_state==PUT_IN)   false_result <= 1'b0;
        //else    false_result <= false_result;
        false_result <= false_result_comb;
    end
end
//true_result
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  true_result <= 'd0;
    else begin
        //if(curr_state==TAKE_OUT && !ptr && !queue[1]) true_result <= 1'b1;
        //else if(curr_state==IDLE)    true_result <= 1'b0;
        //else    true_result <= true_result;
        true_result <= true_result_comb;
    end
end

//queue throw
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  thrown <= 'd0;
    else        thrown <= thrown_comb;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  thrown_d1 <= 'd0;
    else        thrown_d1 <= thrown;
end


//-------------------OUTPUT-------------------------------//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 1'b0;
        result <= 1'b0;
    end
    else begin
        out_valid <= out_valid_comb;
        result <= result_comb;
    end
end

always @(*) begin
    out_valid_comb = 1'b0;
    result_comb = 1'b0;
    if(curr_state==OUTPUT) begin
        out_valid_comb = 1'b1;
        //result_comb = 1'b1;
        //if(true_result) result_comb = 1'b1; //
        //if(false_result) result_comb = 1'b0;
        //if(positive || pat_result)    result_comb = 1'b1;
        if(true_result)             result_comb = 1'b1;
        else                        result_comb = 1'b0;
    end
end


endmodule