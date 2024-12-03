def process_verilog_output(input_text):
    
    input_text = input_text.replace("\n", "").replace(" ", "").replace("output","").replace("wire","")
    tokens = input_text.split(',')
    
    
    outputs = []
    for token in tokens:
        if "[" in token:  
            size = token[token.find("["):token.find("]")+1]  
            name = token[token.find("]")+1:]  
        else:  
            size = ""
            name = token
        outputs.append((name, size))
    
    
    assignments = []
    bit_start = 0
    for name, size in outputs:
        if size:
            
            high_bit, low_bit = map(int, size.strip("[]").split(":"))
            num_bits = high_bit - low_bit + 1
            bit_end = bit_start + num_bits - 1
            assignments.append(f"  assign {name} = prog_data[{bit_end}:{bit_start}];")
            bit_start = bit_end + 1
        else:
            
            assignments.append(f"  assign {name} = prog_data[{bit_start}];")
            bit_start += 1
    
    
    return "\n".join(assignments)



input_text = """

    output wire [7:0] GTHDR,
    output wire [7:0] GTHSNR,
    output wire [3:0] FCHSNR,
    output wire HSNR_EN,
    output wire HDR_EN,
    output wire BG_PROG_EN,
    output wire [3:0] BG_PROG,
    output wire LDOA_BP,
    output wire LDOD_BP,
    output wire LDOD_mode_1V,
    output wire LDOA_tweak,
    output wire [8:0] ATHHI,
    output wire [8:0] ATHLO,
    output wire [4:0] ATO,
    output wire PALPHA,
    output wire DCFILT,
    output wire REF_OUT,
    output wire DRESET,
    output wire HO         

"""

output = process_verilog_output(input_text)
print(output)
