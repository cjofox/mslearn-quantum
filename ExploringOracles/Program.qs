namespace ExploringOracles {

    open Microsoft.Quantum.Canon; //ApplyControlled... ApplyToEach...
    open Microsoft.Quantum.Intrinsic; // X, H, Z
    open Microsoft.Quantum.Arithmetic; 
    // ApplyXorInPlace, Multiply... LittleEndian, MeasureInteger
    open Microsoft.Quantum.Arrays; //ConstantArray, Most, Tail, Enumerated
    open Microsoft.Quantum.Convert; //IntAsDouble
    open Microsoft.Quantum.Math; //Arcsin, sqrt, Round, PI, ComplexPolar
    open Microsoft.Quantum.Preparation; //Prepare...
    open Microsoft.Quantum.Diagnostics; //EqualityFactI, Dump...

    operation IsbnOracle(
        constants : (Int, Int),
        digitReg : Qubit[])
    : Unit is Adj + Ctl {
        use(targetReg, flagQubit) = (Qubit[Length(digitReg)], Qubit());
        within {
            X(flagQubit);
            H(flagQubit);

            //Message("> digitReg before ComputeIsbnCheck:");
            //DumpRegister((), digitReg);
            Message("> targetReg before ComputeIsbnCheck:");
            DumpRegister((), targetReg);
            //Message("> flagQubit before ComputeIsbnCheck:");
            //DumpRegister((), [flagQubit]);

            ComputeIsbnCheck(constants, digitReg, targetReg);

            //Message("<<< digitReg after ComputeIsbnCheck:");
            //DumpRegister((), digitReg);
            Message("<<< targetReg after ComputeIsbnCheck:");
            DumpRegister((), targetReg);
            //Message("<<< flagQubit after ComputeIsbnCheck:");
            //DumpRegister((), [flagQubit]);
        } apply {
            ApplyControlledOnInt(0, X, targetReg, flagQubit);

            //Message("<<< digitReg after apply:");
            //DumpRegister((), digitReg);
            Message("<<< targetReg after apply:");
            DumpRegister((), targetReg);
            //Message("<<< flagQubit after apply:");
            //DumpRegister((), [flagQubit]);
        }
    }

    operation ComputeIsbnCheck(
        constants : (Int, Int),
        digitReg : Qubit[],
        targetReg : Qubit[]
    ) : Unit is Adj + Ctl {
        let (a,b) = constants;
        //Initialize target to b (assumes targetReg is 0)
        ApplyXorInPlace(b, LittleEndian(targetReg));
        // apply mapping: |x>|b> -> |(b+a*x)mod 11>
        // e.g. |x>|9> -> |(9+6*x)mod 11>
        // where digitReg is initial state of x 
        // and targetReg is final state of x
        MultiplyAndAddByModularInteger(a, 11, LittleEndian(digitReg), LittleEndian(targetReg));
    }

    function GetIsbnCheckConstants(digits : Int[]) : (Int, Int) {
        EqualityFactI(Length(digits), 10, "Expected a 10-digit number.");
        // |(b+ax)mod11>
        mutable a = 0;
        mutable b = 0;
        for (idx, digit) in Enumerated(digits) {
            if digit < 0 {
                set a = 10 - idx;
            } else {
                set b += (10-idx) * digit;
            }
        }
        return (a, b%11);
    }
    
    @EntryPoint()
    operation StaticIsbnCheck() : Unit {
        use digitReg = Qubit[4];
        
        //Message("Register before oracle:");
        //DumpRegister((), digitReg);
        let constants = GetIsbnCheckConstants([0, 3, 0, 6, -1, 0, 6, 1, 5, 2]);
        //should return (6, 9);
        IsbnOracle(constants, digitReg);
        
        //Message("Register after oracle:");
        //DumpRegister((), digitReg);
    }
}
