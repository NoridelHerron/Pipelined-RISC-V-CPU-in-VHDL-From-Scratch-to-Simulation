# Pipelined-RISC-V-CPU-in-VHDL-From-Scratch-to-Simulation
## This project is a fully custom, 5-stage pipelined RISC-V CPU built from the ground up in VHDL. 
Each pipeline stage—Instruction Fetch (IF), Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB)—was designed with a modular architecture and verified independently to ensure signal integrity and data flow consistency.

## Key features

- 5-stage pipeline: IF, ID, EX, MEM, WB
- ALU operations, load/store support
- Word-aligned memory interface with internal DATA_MEM
- Pipeline registers for each stage 
- Register file write-back with control signal handling
- Hazard-aware architecture, forwading. Built for future extensions (e.g.  stalls)
- All design and testing done by me as a deep-dive into CPU architecture

## Pipeline Diagram

**Note** You’ll find earlier versions of each pipeline stage in the individual repositories. These earlier modules were initially hardcoded and included design assumptions I later realized were incorrect. Through full system integration, I restructured the design to follow correct pipeline flow and made the architecture scalable and modular.

While some of that early logic has been revised, the documentation and waveforms still offer valuable insight into why certain flags or control signals were implemented the way they were at the time.


- **IF_STAGE** https://github.com/NoridelHerron/INSTRUCTION_FETCH
- **ROM** https://github.com/NoridelHerron/MEMORY_MODULE
- **ID_STAGE** https://github.com/NoridelHerron/ID_STAGE
- **REGISTERS** https://github.com/NoridelHerron/32x32-bit-Register-File-in-VHDL-
- **EX_STAGE** https://github.com/NoridelHerron/EX_STAGE
- **ALU** https://github.com/NoridelHerron/ALU_with_testBenches_vhdl
- **MEM_STAGE** https://github.com/NoridelHerron/MEM_STAGE
- **DATA_MEM** https://github.com/NoridelHerron/DATA_MEM
- **WB_STAGE** https://github.com/NoridelHerron/WB_STAGE

## Project Structure
**PIPELINE**/
- images/
- src/
    - RISCV_CPU.vhd
    - Pipeline_Objects.vhd
    - IF_STA.vhd
        - INST_MEM.vhd
    - IF_TO_ID.vhd
    - DECODER.vhd
        - Register_File.vhd
    - ID_TO_EX.vhd
    - EX_STAGE.vhd
        - ALU_32bits.vhd
            - adder_32bits.vhd
                - FullAdder.vhd
            - sub_32bits.vhd
                - FullSubtractor.vhd
    - EX_TO_MEM.vhd
    - MEM_STA.vhd
        - DATA_MEM.vhd
    - MEM_TO_WB.vhd
    - WB_STA.vhd
    - reusable_function.vhd
    - reusable_func_def_.vhd
- test_benches/
    - tb_RISCV_CPU.vhd
- .gitignore
- README.md

## 🧪 DEBUGGING Strategy
- Integration debugging was guided primarily through waveform analysis, allowing cycle-accurate tracing of pipeline behavior, hazard resolution, and data forwarding.

## 📊 Simulation Results

### Tcl Console Output
![Tcl Output – 5000 Cases](images/tcl.png)  

### Waveform: Memory Read and Memory Write
![Waveform Example – Read](images/wave.png) 

---
## 💡 Key Learnings
- Learned how to organized signals for wave debugging
---

## ▶️ How to Run

1. Launch **Vivado 2019.2** or later
2. Create or open a project and add:
    - `src/*.vhd` (design files)
    - `test_benches/tb_MEM_STAGE.vhd`
3. Set the `test bench` as the simulation top module
4. Run Behavioral Simulation:
    - *Flow > Run Simulation > Run Behavioral Simulation*
5. Increase simulation time if needed
6. Observe:
    - Console output (for pass/fail)
    - Waveform viewer (for data, control, and glitch inspection)
---

## 👤 Author
**Noridel Herron**  
Senior in Computer Engineering – University of Missouri  
✉️ noridel.herron@gmail.com  
GitHub: [@NoridelHerron](https://github.com/NoridelHerron)

---

## 🤝 Contributing
This is a personal academic project. Feedback and suggestions are welcome via GitHub issues or pull requests.

---

## 📜 License
MIT License

---

## ⚠️ Disclaimer
This project is for **educational use only**. Some components may be experimental and are not intended for production use.
