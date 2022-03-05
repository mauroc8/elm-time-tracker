
import { Elm } from './Main.elm';

const elm = Elm.Main.init({
    node: document.getElementById("root"),
    flags: {
        ...storageFlags([ 'createForm', 'recordList', 'settings' ])
    }
})

// --- Storage

elm.ports.setItem.subscribe(({ key, value }: { key: string, value: Json }) => {
    setItem(key, value)
})

type Json = string | number | null | boolean | Json[] | { [key in string]?: Json }

function setItem(key: string, value: Json): void {
    localStorage.setItem(key, JSON.stringify(value))
}

function storageFlags<Stores extends string>(
    stores: Stores[]
): { [Store in Stores]: Json | undefined } {
    return stores.reduce(
        (stores, storeKey) =>
            ({ ...stores, [storeKey]: getItem(storeKey) }),
        {} as { [Store in Stores]: Json | undefined }
    )
}

function getItem(key: string): Json | undefined {
    const str = localStorage.getItem(key)

    if (str === null) {
        return undefined;
    }

    try {
        return JSON.parse(str);
    } catch (e) {
        return undefined;
    }
}
