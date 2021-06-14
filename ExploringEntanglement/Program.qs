namespace ExploringEntanglement {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    
    //example usage: dotnet run --exercise-number 2
    @EntryPoint()
    operation Run(exerciseNumber:Int):Result[]{
        if(exerciseNumber==2){
            return TestEntanglement2();
        }
        else{
            return TestEntanglement1();
        }
    }

    operation TestEntanglement2():Result[]{
        use qubits = Qubit[2];
        H(qubits[0]);
        Controlled X([qubits[0]], qubits[1]); //same as CNOT
        Message("Entangled state before measurement:");
        DumpMachine();
        Message(" ");
        let results = MultiM(qubits);
        Message("State after measurement:");
        DumpMachine();
        return results;
    }


    //create entangled qubits (or a "Bell State") using H and CNOT.
    operation TestEntanglement1() : Result[] {
        use qubits = Qubit[2];
        H(qubits[0]); //superposition (could be 0 or 1 - 50-50 chance) for qubit 0
        CNOT(qubits[0], qubits[1]); //entangled qubits (both qubits either 0 or 1)
        Message("Entangled state before measurement:");
        DumpMachine();
        Message(" ");
        let results = MultiM(qubits);
        Message("State after measurement:");
        DumpMachine();
        return results;
    }
}
