// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/*
    We’re going to do zero knowledge addition again.

    Claim: “I know two rational numbers that add up to num/den”

    Proof: ([A], [B], num, den)

    Keep in mind solidity has a handy function mulmod. Although mulmod does not let you raise to the power of -1, 
    you can accomplish the same thing by raising a number to curve_order - 2. It is recommended you use address 5 
    to do modular exponentiation.
*/

contract RationalNumbers {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    uint256 constant curve_order =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint constant prime =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;
    ECPoint G1;

    constructor() {
        G1 = ECPoint(1, 2);
    }

    function rationalAdd(
        ECPoint calldata A,
        ECPoint calldata B,
        uint256 num,
        uint256 den
    ) public view returns (bool verified) {
        uint256 inv_den = expmod(den, curve_order - 2, curve_order);
        uint256 num_den = mulmod(num, inv_den, curve_order);
        ECPoint memory left = add(A, B);
        ECPoint memory right = scalar_mul(G1, num_den);

        return (left.x == right.x && left.y == right.y);
    }

    function expmod(uint base, uint e, uint m) public view returns (uint o) {
        assembly {
            // define pointer
            let p := mload(0x40)
            // store data assembly-favouring ways
            mstore(p, 0x20) // Length of Base
            mstore(add(p, 0x20), 0x20) // Length of Exponent
            mstore(add(p, 0x40), 0x20) // Length of Modulus
            mstore(add(p, 0x60), base) // Base
            mstore(add(p, 0x80), e) // Exponent
            mstore(add(p, 0xa0), m) // Modulus
            if iszero(staticcall(sub(gas(), 2000), 0x05, p, 0xc0, p, 0x20)) {
                revert(0, 0)
            }
            // data
            o := mload(p)
        }
    }

    function add(
        ECPoint memory p1,
        ECPoint memory p2
    ) internal view returns (ECPoint memory r) {
        uint256[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * @return r the product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(
        ECPoint memory p,
        uint256 s
    ) internal view returns (ECPoint memory r) {
        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-mul-failed");
    }
}
