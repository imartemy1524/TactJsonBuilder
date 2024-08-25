import { toNano } from '@ton/core';
import { JsonBuilder } from '../wrappers/JsonBuilder';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const jsonBuilder = provider.open(await JsonBuilder.fromInit());

    await jsonBuilder.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(jsonBuilder.address);

    // run methods on `jsonBuilder`
}
