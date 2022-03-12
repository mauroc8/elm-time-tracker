
import { Elm } from './Main.elm';

const elm = Elm.Main.init({
    node: document.getElementById("root"),
    flags: {
        createForm: readStore('createForm'),
        recordList: readStore('recordList'),
        settings: readStore('settings')
    }
})

// --- LocalStorage

elm.ports.setItem.subscribe(({ key, value }: { key: string, value: Json }) => {
    setItem(key, value)
})

type Json = string | number | null | boolean | Json[] | { [key in string]?: Json }

function setItem(key: string, value: Json): void {
    localStorage.setItem(key, JSON.stringify(value))
}

/** Reads a Json value from the store, or returns `null` */
function readStore(key: string): Json {
    const str = localStorage.getItem(key)

    try {
        return str && JSON.parse(str);
    } catch (e) {
        return null;
    }
}

// --- PreventClose

elm.ports.setPreventClose.subscribe((preventClose: boolean) => {
    window.onbeforeunload = preventClose
        ? askForCloseConfirmation
        : null;
});

function askForCloseConfirmation(event: any) {
    return (event || window.event).returnValue = "Are you sure?";
}
