namespace ExploringGroversSearch {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    
    //part 1
    //@EntryPoint()
    operation SolveGraphColoringProblem() : Unit {
        let nVertices = 5;
        let edges = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3),(3,4)];

        //coloring array makes more sense seeing bits after chunking.
        let coloring = [false,false,true,false,false,true,true,true,true,false];
        let colors =  ["red","green","blue","yellow"];
        
        //color bits for each vertex after chunking into pairs
        let colorBits = Chunks(2, coloring);
        Message($"Color bits: {colorBits}");
        Message($"colorBits[1]: {colorBits[1]}");
        Message($"BoolArrayAsInt(colorBits[1]): {BoolArrayAsInt(colorBits[1])}");
        for i in 0 .. nVertices -1 {
            //little endian bits - "10" is 1 and "01" is 2 as an int.
            let colorIndex = BoolArrayAsInt(colorBits[i]);
            Message($"Vertex {i} - color #{colorIndex} ({colors[colorIndex]})");
        }
    }

    //part 2
    //@EntryPoint()
    operation ShowColorEqualityCheck() : Unit {
        use (c0, c1, target) = (Qubit[2], Qubit[2], Qubit());
        ApplyToEach(H, c0 + c1);
        //compare to only superposition on c1:
        //ApplyToEach(H, c1);

        Message("The starting state of qubits c1 and target:");
        DumpRegister((), c1 + [target]);
        //compare with dumping all registers:
        //DumpRegister((), c0 + c1 + [target]);

        MarkColorEquality2(c0, c1, target, true);

        Message("");
        Message("The state of qubits c1 and target after the equality check:");
        DumpRegister((), c1 + [target]);

        ResetAll(c0 + c1 + [target]);
    }

    operation MarkColorEquality(c0: Qubit[], c1 : Qubit[], target  : Qubit) : Unit is Adj+Ctl {
        MarkColorEquality2(c0, c1, target, false);
    }

    operation MarkColorEquality2(c0: Qubit[], c1 : Qubit[], target  : Qubit, debug: Bool) : Unit is Adj+Ctl {
        within {
            if(debug){
                Message("c1, target:");
                DumpRegister((), c1 + [target]);
            }
            for(q0, q1) in Zipped(c0, c1) {
                if(debug){
                    Message("q0:");
                    DumpRegister((), [q0]);

                    //q1 is entangled with other qubit in c1 and target,
                    //so q1 can't be displayed for all calls to this function. 
                    //following line throws the following error message:
                    //"Qubits were entangled with an external qubit. 
                    //Cannot dump corresponding wave function."
                    //DumpRegister((), [q0, q1, target]);
                }

                //xor q0(control) and q1(target), store in q1
                //does this have any effect when c0=|00>?
                CNOT(q0, q1);
                if(debug){
                    Message("q0 after CNOT(q0, q1):");
                    DumpRegister((), [q0]);
                    Message("q1 after CNOT(q0, q1):");
                    DumpRegister((), [q1]);
                    Message("q0+q1 after CNOT(q0, q1):");
                    DumpRegister((), [q0,q1]);
                }
            }
        } apply {
            //if xor'd qubits gives 0, both same, flip target state
            (ControlledOnInt(0, X))(c1, target);
        }
    }

    //part 3
    operation MarkValidVertexColoring(
        edges : (Int, Int)[],
        colorsRegister : Qubit[],
        target : Qubit
    ) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let colors = Chunks(2, colorsRegister);
        use conflictQubits = Qubit[nEdges];
        within{
            for((start, end), conflictQubit) in Zipped(edges, conflictQubits) {
                MarkColorEquality(colors[start], colors[end], conflictQubit);
            }
        } apply {
            (ControlledOnInt(0, X))(conflictQubits, target);
        }
    }

    //part 3
    //@EntryPoint()
    operation ShowColoringValidationCheck() : Unit {
        let nVertices = 5;
        let edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3), (3, 4)];
        //valid coloring:
        let coloring = [false, false, true, false, false, true, true, true, false, true];
        //invalid coloring (same color for vertices 3 and 4):
        //let coloring = [false, false, true, false, false, true, true, true, true, true];
        use (coloringRegister, target)=(Qubit[2*nVertices],Qubit());
        Message("coloringRegister[0..9]:");
        //dumping all qubits together produces 1023 lines (2^10-1)
        //DumpRegister((), coloringRegister);
        for i in 0..9{
            DumpRegister((), [coloringRegister[i]]);
        }
        //apply the state of coloring to register
        ApplyPauliFromBitString(PauliX, true, coloring, coloringRegister);
        //applying coloring gives 1 for true and 0 for false:
        //0010 0111 01 (little endian)
        //10 1110 0100b (big endian)
        //or 740 base10
        Message("");
        Message("coloringRegister[0..9] after PauliX:");
        for i in 0..9{
            DumpRegister((), [coloringRegister[i]]);
        }

        //applying Hadamard requires looking at phase, not amplitude
        //ApplyToEach(H, coloringRegister);
        //Message("");
        //Message("coloringRegister[0..9] after H:");
        //for i in 0..9{
        //    DumpRegister((), [coloringRegister[i]]);
        //}

        MarkValidVertexColoring(edges, coloringRegister, target);
        
        let isColoringValid = M(target) == One;
        Message("");
        Message($"The coloring is {isColoringValid?"valid"|"invalid"}");
        
        ResetAll(coloringRegister);
    }

    operation ApplyMarkingOracleAsPhaseOracle(
        markingOracle : ((Qubit[], Qubit[], Qubit) => Unit is Adj),
        c0 : Qubit[],
        c1 : Qubit[]
        ) : Unit is Adj {
        use target = Qubit();
        within{
            // Put target qubit into |-> state
            X(target);
            H(target);
        } apply{
            markingOracle(c0, c1, target);
        }
    }

    @EntryPoint()
    operation ShowPhaseKickbackTrick() : Unit {
        use (c0, c1) = (Qubit[2], Qubit[2]);
        ApplyToEach(H, c1);

        Message("The starting state of qubits c1:");
        DumpRegister((), c1);

        ApplyMarkingOracleAsPhaseOracle(MarkColorEquality, c0, c1);

        Message("");
        Message("The state of qubits c1 after the equality check:");
        DumpRegister((), c1);

        ResetAll(c1);
    }
}
