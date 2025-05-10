# Pipelined-RISC-V-CPU-in-VHDL-From-Scratch-to-Simulation
This project is a fully custom, 5-stage pipelined RISC-V CPU designed and implemented in VHDL. It was built from scratch, stage by stage, with modular structure and thorough testing. Each pipeline stage—IF, ID, EX, MEM, and WB—was verified independently to ensure signal correctness and data consistency.

## Key features

- 5-stage pipeline: IF, ID, EX, MEM, WB
- ALU operations, load/store support, branching logic
- Word-aligned memory interface with internal DATA_MEM
- Pipeline registers for each stage 
- Register file write-back with control signal handling
- Hazard-aware architecture, built for future extensions (e.g. forwarding, stalls)
- Waveform-based simulation and debugging
- All design and testing done by me as a deep-dive into CPU architecture

## Pipeline Diagram
![Pipeline Diagram with no complexity no branching and jumping yet](images/pipeline_diagram.png)  


**Note** Explore the repositories for each stage and review the documentation and waveforms for insight into the design and verification process.
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
- test_benches/
- .gitignore
- README.md

## 🧪 Testbench Strategy
- Group by stage

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
