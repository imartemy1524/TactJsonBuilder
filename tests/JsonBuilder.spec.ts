import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Dictionary, toNano } from '@ton/core';
import { JsonBuilder } from '../wrappers/JsonBuilder';
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
                value: new Dictionary<bigint, Employee>()
                    .set(123, { name: 'Ivan', age: 19, salary: toNano('10') })
                    .set(124, { name: 'Petr', age: 20, salary: toNano('20') })
                    .set(1923, { name: 'Sidor', age: 21, salary: toNano('30') }),
            },
        );
        expect(transactions).toHaveTransaction({
            from: jsonBuilder.address,
            to: jsonBuilder.address,
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
