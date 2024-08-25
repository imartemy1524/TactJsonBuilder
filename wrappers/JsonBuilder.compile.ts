import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/json_builder.tact',
    options: {
        debug: true,
    },
};
