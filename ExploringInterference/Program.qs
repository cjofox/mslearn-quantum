namespace ExploringInterference {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;

    //usage example: dotnet run --exercise=TestInterference3
    @EntryPoint()
    operation Run(exercise:String):Unit{
        if(exercise == "TestInterference3"){
            TestInterference3();
        }
        elif(exercise == "TestInterference2"){
            TestInterference2();
        }
        else{
            let result = TestInterference1();
            Message("{result}");
        }
    }

    operation TestInterference3():Unit{
        use q = Qubit(); //initial state: |0>
        Message("Initial state:");
        DumpMachine();
        Y(q); //set state to i|1>
        Message("After Y(q):");
        DumpMachine();
        H(q); //set state to 0.7i|0> -0.7i|1>
        Message("After H(q):");
        DumpMachine();
        Reset(q);
    }

    operation TestInterference2():Unit{
        use q = Qubit();
        X(q); //set state to |1>
        H(q); //uniform superposition, but |1> is negative (pi radians).
        DumpMachine();
        Reset(q);
    }
    
    //applying H twice gives back |0> state.
    operation TestInterference1() : Result {
        use q = Qubit();
        Message("\nAt the beginning the qubit is in the state |0>.");
        DumpMachine();
        H(q);
        Message("\nAfter applying H the qubit is in a uniform superposition.");
        DumpMachine();
        H(q);
        Message("\nIf we apply H again, interference gives back the state |0>.");
        DumpMachine();
        Message("\nIf we measure we always obtain 'Zero'.");
        return MResetZ(q);

    }
}
