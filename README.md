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

## Open Questions
Design Question — Port Entry vs Internal Signal

As I was building my pipeline registers and debugging signal flow, I started wondering about the trade-offs between two design choices:

- Option 1: Expose signals as port entries between modules
- Option 2: Keep signals internal and connect them through internal logic

Questions I’m still exploring:
	-	From a design clarity and maintainability perspective, which approach scales better as the system grows?
	-	From a hardware synthesis / resource cost perspective, does using ports introduce more overhead than using internal signals?
	-	Are there any best practices or guidelines for when to prefer one over the other in pipeline register design?

If anyone has insights or resources on this, I would love to learn! I’d like to apply better-informed decisions on my next project.

## Pipeline Diagram
**Note**: Will do this once everything is completed.

**Note**: You’ll find earlier versions of each pipeline stage in the individual repositories. These earlier modules were initially hardcoded and included design assumptions I later realized were incorrect. Through full system integration, I restructured the design to follow correct pipeline flow and made the architecture scalable and modular.

While some of that early logic has been revised, the documentation and waveforms still offer valuable insight into why certain flags were implemented the way they were at the time.

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
    - RISCV_CPU.vhd (Main)
    - Pipeline_Objects.vhd (Constant, type declaration, and initialization)
    - IF_STA.vhd
        - INST_MEM.vhd (Instruction Memory)
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
        - DATA_MEM.vhd (Data Memory)
    - MEM_TO_WB.vhd
    - WB_STA.vhd
    - reusable_function.vhd
    - reusable_func_def_.vhd
- test_benches/
    - tb_RISCV_CPU.vhd
- .gitignore
- README.md

## Decisions


## 🧪 DEBUGGING Strategies

### Wave debugging

**Note**: If you're a beginner like me, don’t do what I did — avoid trying to add too many instructions at once! Start with just a couple of known instructions and add more as you get comfortable. Otherwise, you’ll start seeing "double" in the waveforms. 

**Additional Note**: Be patient — debugging is a skill that improves with practice.

![PCs and Instructions](images/pc_instr.png) 
**Where did I start?**
    - I began by focusing on the Program Counter (PC) and the instruction being fetched (IF stage), starting at 25 ns.
I checked whether, as each instruction was fetched, the PC was incrementing by 4 as expected — meaning it was moving to the next instruction correctly.

But it’s not enough to just check that the PC increments. I also needed to confirm that this happens in exactly **one cycle**. If it takes longer than one cycle, that’s a sign something is wrong and I would need to investigate further.

**How did I confirm the pipeline is working properly?** 
To verify that the pipeline stages were functioning as intended, I observed the flow of instructions across each stage in the waveform viewer.
In this test:
    The first instruction entered the IF stage at 25 ns and completed the pipeline at 75 ns — meaning it took exactly **5 clock cycles** to pass through all 5 stages, as expected.

Here’s how the pipeline filled:
**Cycle 1**: Instruction 1 in IF
**Cycle 2**: Instruction 1 in ID, Instruction 2 in IF
**Cycle 3**: Instruction 1 in EX, Instruction 2 in ID, Instruction 3 in IF
And so on — each instruction advances one stage per clock cycle.
    
This confirmed that my pipeline was flowing correctly: no stages were skipped, and instructions advanced in a staggered manner through the pipeline.

![Register between IF and ID stage](images/IF_ID_reg.png) 
**Next, How do I know if the decoding stage is doing its job and where to look.** 
    For the first instruction, I looked at 35 ns.
    At that point, you won’t see the decoded value yet — because it takes one full cycle for it to update. You’ll see the correct decoded value in the following cycle.

This same pattern applies to every stage: the data you expect will appear one cycle later than the trigger event. It’s important to understand this when reading the waveform — otherwise, you might think something is broken when it isn’t!

**Tip**: Using a **record type** for your pipeline signals makes your code much cleaner and easier to debug. In the waveform viewer, records are displayed as expandable groups. This allows you to quickly spot problems — if you see a signal that is not green, you can expand the record and immediately pinpoint which field is incorrect.

However, just seeing "all green" does not guarantee that everything is working correctly. You still need to carefully check that each value matches your expectations and is appearing at the correct stage and cycle. If something looks off, go back and investigate — even if the signal colors look fine.

![Showing what I expected](images/as_expected.png) 

**Reflection**:
When everything looks as expected in the waveform, that usually means your implementation is correct.

But be careful — sometimes the problem is not in how we implemented it, but in what we believed was correct in the first place. If the design or our understanding is wrong, the implementation can appear "correct" — but the CPU will still not behave as intended.

### Tcl Console technique
For the full pipeline integration, I did not use the Tcl console extensively yet — because I am still building a solid understanding of how pipelined CPUs work. My goal is to improve this as I progress through the project. If anyone has recommendations or best practices for using Tcl console in this context, I would love to learn from them.

However, here is the general approach I used when testing individual modules:
- I used a variable to track whether each test passed or failed.
- If any test failed, I added a separate "fail tracking" variable to help locate the issue.
- I also inserted additional assertions at key points where I suspected things could go wrong.
- From there, I systematically narrowed down the bugs by following the failing signals.

This method helped me debug module-level behavior even without fully using Tcl automation yet. I plan to expand this technique as I become more comfortable with pipeline-level debugging.

---
## 💡 Key Learnings
- Learned how to organized signals for wave debugging
---

## ▶️ How to Run

1. Launch **Vivado 2019.2** or later
2. Create or open a project and add:
    - `src/*.vhd` (design files)
    - `test_bench/*.vhd`
3. Set the `test bench` as the simulation top module
4. Run Behavioral Simulation:
    - *Flow > Run Simulation > Run Behavioral Simulation*
5. Increase simulation time if needed
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
