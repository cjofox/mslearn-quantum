namespace ExploringGroversSearchAlgorithm {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // Generic Search
    operation RunGroversSearch(
        register : Qubit[],
        phaseOracle : ((Qubit[]) => Unit is Adj),
        iterations : Int
    ) : Unit {
        ApplyToEach(H, register);

        for _ in 1..iterations {
            phaseOracle(register);
            within{
                ApplyToEachA(H, register);
                ApplyToEachA(X, register);
            } apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
    }

    operation ApplyMarkingOracleAsPhaseOracle(
        markingOracle : ((Qubit[], Qubit) => Unit is Adj),
        register : Qubit[]
    ) : Unit is Adj {
        use target = Qubit();
        within {
            X(target);
            H(target);
        } apply {
            markingOracle(register, target);
        }
    }

    //part of marking oracle
    operation MarkColorEquality(
        c0 : Qubit[],
        c1 : Qubit[],
        target : Qubit
    ) : Unit is Adj + Ctl {
        within {
            for (q0, q1) in Zipped(c0, c1) {
                CNOT(q0, q1);
            }
        } apply {
            (ControlledOnInt(0, X))(c1, target);
        }
    }

    //marking oracle
    operation MarkValidVertexColoring(
        edges : (Int, Int)[],
        colorRegister : Qubit[],
        target : Qubit
    ) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let colors = Chunks(2, colorRegister);
        use conflictQubits = Qubit[nEdges];
        within {
            for ((start, end), conflictQubit) in Zipped(edges, conflictQubits) {
                MarkColorEquality(colors[start], colors[end], conflictQubit);
            }
        } apply {
            (ControlledOnInt(0, X))(conflictQubits, target);
        }
    }
    
    //specific problem to solve
    @EntryPoint()
    operation SolveGraphColoringProblem() : Unit {
        let nVertices = 5;
        let edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3), (3, 4)];
        
        let markingOracle = MarkValidVertexColoring(edges, _, _);
        let phaseOracle = ApplyMarkingOracleAsPhaseOracle(markingOracle, _);

        let nQubits = 2 * nVertices;
        let searchSpaceSize = 2 ^ (nQubits);
        let nSolutions = 72;
        let nIterations = Round(PI()/4.0*Sqrt(IntAsDouble(searchSpaceSize)/IntAsDouble(nSolutions)));
        
        mutable answer = new Bool[nQubits];
        use (register, output) = (Qubit[nQubits], Qubit());
        mutable isCorrect = false;

        repeat {
            RunGroversSearch(register, phaseOracle, nIterations);
            let res = MultiM(register);
            markingOracle(register, output);
            if(MResetZ(output) == One) {
                set isCorrect = true;
                set answer = ResultArrayAsBoolArray(res);
            }
            ResetAll(register);
        } until (isCorrect);

        let colorBits = Chunks(2, answer);
        Message("The resulting graph coloring:");
        for i in 0..nVertices-1 {
            Message($"Vertex {i} - color {BoolArrayAsInt(colorBits[i])}");
        }
    }
}
