import { Blockchain, printTransactionFees, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Dictionary, toNano } from '@ton/core';
import { Employee, JsonBuilder } from '../wrappers/JsonBuilder';
import '@ton/test-utils';

describe('JsonBuilder', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let jsonBuilder: SandboxContract<JsonBuilder>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        jsonBuilder = blockchain.openContract(await JsonBuilder.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await jsonBuilder.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: jsonBuilder.address,
            deploy: true,
            success: true,
        });
    });

    it('should send JSON', async () => {
        const { transactions } = await jsonBuilder.send(
            deployer.getSender(),
            { value: toNano('1') },
            {
                $$type: 'MapMessage',
                data: Dictionary.empty<bigint, Employee>()
                    .set(123n, { name: 'Ivan', age: 19n, salary: toNano('10'), $$type: 'Employee' })
                    .set(124n, { name: 'Petr', age: 20n, salary: toNano('20'), $$type: 'Employee' })
                    .set(1923n, { name: 'Sidor', age: 21n, salary: toNano('30'), $$type: 'Employee' }),
            },
        );
        printTransactionFees(transactions);
        expect(transactions).toHaveTransaction({
            from: jsonBuilder.address,
            to: deployer.address,
            body: (body) => {
                try {
                    const data = body!.beginParse();
                    data.loadUint(32);
                    const commentJSON = data.loadStringTail();
                    //this can throw error
                    JSON.parse(commentJSON);
                    return true;
                } catch (e) {
                    console.error(e);
                    return false;
                }
            },
        });
    });
});
