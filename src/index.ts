
import { Elm } from './Main.elm';
import './styles.css'

const elm = Elm.Main.init({
    node: document.getElementById("root"),
    flags: {
        createForm: getItem('createForm'),
        recordList: getItem('recordList'),
        settings: getItem('settings')
    }
})

// --- LocalStorage

elm.ports.setItem.subscribe(({ key, value }: { key: string, value: Json }) => {
    setItem(key, value)
})

type Json = string | number | null | boolean | Json[] | { [key in string]?: Json }

/** Sets a localStorage item with a Json value */
function setItem(key: string, value: Json): void {
    localStorage.setItem(key, JSON.stringify(value))
}

/** Returns a Json value from localStorage, or `null` */
function getItem(key: string): Json {
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
    return (event || window.event).returnValue =
        // Modern browsers ignore this message
        "Are you sure?";
}
