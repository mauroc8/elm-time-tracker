
import { Elm } from './Main.elm';
import './styles.css'

const elm = Elm.Main.init({
    node: document.getElementById("root"),
    flags: {
        createForm: getItemOrNull('createForm'),
        recordList: getItemOrNull('recordList'),
        settings: getItemOrNull('settings')
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
function getItemOrNull(key: string): Json {
    const str = localStorage.getItem(key)

    try {
        return str && JSON.parse(str);
    } catch (e) {
        return null;
    }
}

// --- PreventClose

elm.ports.setPreventClose.subscribe((preventClose: boolean) => {
    function askForCloseConfirmation(event: any) {
        return (event || window.event).returnValue =
            // Modern browsers ignore this message
            "Are you sure?";
    }

    window.onbeforeunload = preventClose
        ? askForCloseConfirmation
        : null;
});

// --- Favicon

elm.ports.setFavicon.subscribe((favicon: 'play' | 'stop') => {
    const node = (document.querySelector('link[rel="icon"]')
        || document.head.appendChild(Object.assign(document.createElement('link'), { rel: 'icon' }))) as HTMLLinkElement;

    if (node) switch (favicon) {
        case 'play':
            node.href = "/play.ico";
            break;

        case 'stop':
            node.href = "/stop.ico";
            break;

        default: {
            const _: never = favicon;
            
            console.error('setFavicon received invalid input', { favicon });
        }
    }
});
