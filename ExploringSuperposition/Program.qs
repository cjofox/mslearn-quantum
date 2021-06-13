namespace ExploringSuperposition {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    //third exercise: view state after each qubit measurement.
    @EntryPoint()
    operation GenerateUniformState():Int{
        use qubits = Qubit[3];
        ApplyToEach(H, qubits);
        Message("The qubit register in a uniform superposition:");
        DumpMachine();
        mutable results = new Result[0];
        for q in qubits{
            Message(" ");
            set results += [M(q)];
            DumpMachine();
        }
        Message(" ");
        Message("Your random number is: ");
        return ResultArrayAsInt(results);
    }

    operation ResultArrayAsInt(input:Result[]):Int{
        return BoolArrayAsInt(ResultArrayAsBoolArray(input));
    }

    //second exercise: random number generation with DumpMachine to analyse state.
    //comment other operations and uncomment the next line to use: 
    //@EntryPoint()
    operation GenerateRandomNumber():Int{
        use qubits = Qubit[3];
        ApplyToEach(H, qubits);
        Message("The qubit register in a uniform superposition:");
        DumpMachine();
        let results = ForEach(M, qubits);
        Message("Measuring the qubits collapses the superposition to a basis state.");
        DumpMachine();
        return ResultArrayAsInt(results);
    }

    //first exercise:creating a skewed random split, 
    //e.g. pass alpha of 0.333 for approximately third - two third split.
    //usage: dotnet run --alpha 0.333
    //comment other operations and uncomment the next line to use: 
    //@EntryPoint()
    operation GenerateSpecificState(alpha:Double):Result{
        use q = Qubit();
        Ry(2.0*ArcCos(Sqrt(alpha)), q);
        Message("The qubit is in the desired state.");
        Message("");
        DumpMachine();
        Message("");
        Message("Your skewed random bit is:");
        return M(q);
    }
}
