const { constants } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { BigNumber } = require('ethers');

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const MAX_UINT256 = BigNumber.from('115792089237316195423570985008687907853269984665640564039457584007913129639935');

describe('RationalNumbers', function () {
    var initialHolder;
    var recipient;
    var anotherAccount;
    var token;

    beforeEach(async function () {
        [initialHolder, recipient, anotherAccount] = await ethers.getSigners();
        const RationalNumbers = await ethers.getContractFactory("RationalNumbers");
        token = await RationalNumbers.deploy();
    });

    describe('Call rationalAdd', function () {

        // 8 / 12 + 1 / 12 = 9 / 12 (3/4)
        it('works correctly for positive case', async function () {
            var A = {
                x: BigNumber.from('4044475655963335105874705693887717986734082637953872334734275921521622691675'),
                y: BigNumber.from('6961300548333041600164002436990239666696562973977691579804530869930595532137')
            };
            var B = {
                x: BigNumber.from('15514098174231388526936394909884819852161713760351236454286095935185347406190'),
                y: BigNumber.from('16207293035697985973521572619574413772437159530764812837532719998459133339912')
            };
            var nom = 3;
            var denom = 4;
            expect(await token.rationalAdd(A, B, nom, denom)).to.be.true;
        });

        // 9/12 + 1/12 != 9/12 (3/4)
        it('works correctly for negative case', async function () {
            var A = {
                x: BigNumber.from('2857625431839718922471812833357737477490018756027287331750692909542658596388'),
                y: BigNumber.from('1911129795864509240059974873783816568594673160967429852131769465429209708149')
            };
            var B = {
                x: BigNumber.from('15514098174231388526936394909884819852161713760351236454286095935185347406190'),
                y: BigNumber.from('16207293035697985973521572619574413772437159530764812837532719998459133339912')
            };
            var nom = 3;
            var denom = 4;
            expect(await token.rationalAdd(A, B, nom, denom)).to.be.false;
        });
    });
});
