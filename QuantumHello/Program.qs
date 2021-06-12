namespace QuantumRNG {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    operation GenerateRandomBit() : Result {
        use qubit = Qubit();
        H(qubit);
        return M(qubit);
    }

    operation SampleRandomNumberInRange(min:Int, max:Int):Int{
        mutable output = 0;
        repeat {
            mutable bits = new Result[0];
            for idxBit in 1..BitSizeI(max){
                set bits +=[GenerateRandomBit()];
            }
            set output = ResultArrayAsInt(bits);
        } until (output <= max and output >= min);
        return output;
    }

    @EntryPoint()
    operation GenerateManyRandomNumbers():Unit{
        let count = 10;
        let min = 10;
        let max = 20;
        Message($"Generate {count} random numbers between {min} and {max}:");
        for c in 1..count{
            Message($"{SampleRandomNumberInRange(min, max)}");
        }
    }

}
