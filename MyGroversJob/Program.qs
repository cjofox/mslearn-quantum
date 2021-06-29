namespace MyGroversJob {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    
    operation ReflectAboutUniform(inputQubits:Qubit[]):Unit{
        within{
            ApplyToEachCA(H, inputQubits);
            ApplyToEachCA(X, inputQubits);
        } apply {
            Controlled Z(Most(inputQubits), Tail(inputQubits));
        }
    }

    operation RunGroversSearch(
        register:Qubit[], 
        phaseOracle:((Qubit[]) => Unit is Adj),
        iterations:Int
    ) : Unit {
            ApplyToEachCA(H, register);
            for _ in 1..iterations {
                phaseOracle(register);
                ReflectAboutUniform(register);
            }
    }

    operation MarkingNumber(
        idxMarked:Int,
        inputQubits:Qubit[],
        target:Qubit
    ) : Unit is Adj + Ctl {
        ControlledOnInt(idxMarked, X)(inputQubits, target);
    }

    operation ApplyMarkingOracleAsPhaseOracle(
        markingOracle:((Qubit[],Qubit) => Unit is Adj),
        register:Qubit[]
    ) : Unit is Adj {
        use target = Qubit();
        within{
            X(target);
            H(target);
        } apply{
            markingOracle(register, target);
        }
    }

    function NIterations(nQubits:Int) : Int {
        let nItems = 1 <<< nQubits;
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    @EntryPoint()
    operation GroversTest(nQubits:Int, idxMarked:Int) : Result[] {
        let markingOracle = MarkingNumber(idxMarked, _, _);
        let phaseOracle = ApplyMarkingOracleAsPhaseOracle(markingOracle, _);
        let nIterations = NIterations(nQubits);

        use qubits = Qubit[nQubits];
        RunGroversSearch(qubits, phaseOracle, nIterations);
        return ForEach(MResetZ,qubits);
    }
}


