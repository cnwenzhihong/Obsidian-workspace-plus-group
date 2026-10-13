const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { test } = require("node:test");

const source = fs.readFileSync(path.join(__dirname, "../main.js"), "utf8");
const workspaceStart = source.indexOf("class WorkspacesPlusPluginWorkspaceModal ");
const modeStart = source.indexOf("class WorkspacesPlusPluginModeModal ");
const modalSource = source.slice(workspaceStart, source.indexOf("function around(", modeStart));

class ElementStub {
    constructor() {
        this.classList = { add() {}, contains() { return false; } };
        this.parentElement = this;
        this.value = "";
        this.style = {};
        this.contentEditable = "false";
        this.listeners = {};
    }
    setAttribute() {}
    on() {}
    addEventListener(name, callback) { this.listeners[name] = callback; }
    cloneNode() { return new ElementStub(); }
    insertBefore() {}
    toggleClass() {}
    scrollIntoViewIfNeeded() {}
    detach() { this.isConnected = false; }
}

// Optional integration with locally installed Obsidian; never copy runtime code into the repo.
function readNativeMethods(asarPath) {
    const archive = fs.readFileSync(asarPath);
    const header = JSON.parse(archive.subarray(16, 16 + archive.readUInt32LE(12)));
    const entry = header.files["app.js"];
    const offset = 8 + archive.readUInt32LE(4) + Number(entry.offset);
    const app = archive.subarray(offset, offset + entry.size).toString("utf8");
    const start = app.indexOf("this.shouldRestoreSelection=!0,this.selection=null");
    assert.ok(start >= 0, "Installed Modal implementation must be identified");
    const modal = app.slice(start, app.indexOf("e.prototype.setTitle=", start));
    const extract = (name, next) => {
        const marker = `e.prototype.${name}=`;
        const begin = modal.indexOf(marker);
        const end = modal.indexOf(`,e.prototype.${next}=`, begin);
        assert.ok(begin >= 0 && end > begin, `Native Modal.${name} must be identified`);
        return modal.slice(begin + marker.length, end);
    };
    return { open: extract("open", "animateOpen"), close: extract("close", "onOpen") };
}

function fixture(kind, hotkey, nativeMethods) {
    const parentScope = {};
    const scopes = [parentScope];
    const parentModal = {};
    const closables = [parentModal];
    const loads = [];
    const saves = [];
    const poppers = [];
    const body = {
        appendChild(el) { el.isConnected = true; },
        querySelector() { return new ElementStub(); },
    };
    const workspacePlugin = {
        activeWorkspace: "Alpha",
        workspaces: { Alpha: {}, Beta: {}, "Mode: Alpha": {}, "Mode: Beta": {} },
        saveWorkspace(name) { saves.push(name); },
        loadWorkspace(name) { loads.push(name); },
        setActiveWorkspace(name) { this.activeWorkspace = name; },
    };
    const app = {
        keymap: {
            pushScope(scope) { scopes.push(scope); },
            popScope(scope) {
                assert.equal(scopes.at(-1), scope, "Only the modal's own scope may be popped");
                scopes.pop();
            },
        },
        workspace: { pushClosable(modal) { closables.push(modal); } },
        internalPlugins: { getPluginById() { return { instance: workspacePlugin }; } },
    };
    class FuzzySuggestModal {
        constructor(app) {
            this.app = app;
            this.isOpen = false;
            this.containerEl = new ElementStub();
            this.bgEl = new ElementStub();
            this.modalEl = new ElementStub();
            this.inputEl = new ElementStub();
            const input = this.inputEl;
            this.resultsEl = new ElementStub();
            this.modalEl.querySelector = selector => selector === ".prompt-input" ? input : this.resultsEl;
            this.chooser = {
                values: [{ item: "Alpha" }, { item: "Beta" }],
                selectedItem: 0,
                suggestions: [new ElementStub(), new ElementStub()],
                setSelectedItem(index) { this.selectedItem = index; },
                chooser: { updateSuggestions() {} },
            };
            this.bgEl.addEventListener("click", () => this.close());
            this.closeButton = new ElementStub();
            this.closeButton.addEventListener("click", () => this.close());
        }
        setPlaceholder() {}
        getRootEl() { return this.containerEl; }
        canAnimate() { return false; }
        onOpen() { this.baseOpenCount = (this.baseOpenCount || 0) + 1; }
        onClose() { this.baseCloseCount = (this.baseCloseCount || 0) + 1; }
        selectSuggestion(item, evt) { this.close(); this.onChooseItem(item.item, evt); }
        // Legacy contract fixture: attachment and scope are managed by native open/close.
        open() {
            if (this.containerEl.isConnected) return;
            this.app.keymap.pushScope(this.scope);
            body.appendChild(this.containerEl);
            this.app.workspace.pushClosable(this);
            this.onOpen();
        }
        close() {
            if (!this.containerEl.isConnected) return;
            this.app.keymap.popScope(this.scope);
            this.containerEl.detach();
            closables.splice(closables.indexOf(this), 1);
            this.onClose();
        }
    }
    class Scope {
        constructor() { this.bindings = new Map(); }
        register(modifiers, key, callback) { this.bindings.set([...modifiers, key].join("+"), callback); }
    }
    const plugin = {
        app, settings: { workspaceChildren: {} },
        getItems() { return ["Alpha", "Beta"]; },
        getWorkspaceChildren() { return []; },
        getWorkspaceParent() { return null; },
        getModalCollapseState() { return {}; },
        registerWorkspaceHotkeys() {},
    };
    const activeWindow = { document: { body } };
    const context = vm.createContext({
        obsidian: { FuzzySuggestModal, Scope, Notice: class {} },
        t: key => key,
        createDiv: () => new ElementStub(),
        createPopper: () => {
            const popper = { destroyed: 0, destroy() { this.destroyed++; } };
            poppers.push(popper);
            return popper;
        },
        document: { body },
        window: activeWindow,
        activeWindow,
        Qy: { hasPhysicalKeyboard: false },
        cE() {}, Uw() {}, CS() {}, iS() {},
        yM: {
            push(modal) { closables.push(modal); },
            pop(modal) { closables.splice(closables.indexOf(modal), 1); },
        },
    });
    if (nativeMethods) {
        FuzzySuggestModal.prototype.open = vm.runInContext(`(${nativeMethods.open})`, context);
        FuzzySuggestModal.prototype.close = vm.runInContext(`(${nativeMethods.close})`, context);
        delete app.workspace.pushClosable;
    }
    const Modal = vm.runInContext(`${modalSource}\n${kind}`, context);
    const modal = new Modal(plugin, plugin.settings, hotkey);
    modal.shouldRestoreSelection = false;
    return { modal, scopes, parentScope, closables, parentModal, loads, saves, poppers };
}

const runtimes = [["legacy contract", null]];
if (process.env.OBSIDIAN_ASAR)
    runtimes.push(["installed native Modal", readNativeMethods(process.env.OBSIDIAN_ASAR)]);

for (const [runtime, nativeMethods] of runtimes) {
    for (const kind of ["WorkspacesPlusPluginWorkspaceModal", "WorkspacesPlusPluginModeModal"]) {
        if (nativeMethods) {
            test(`${runtime}: ${kind}, bypassing native open reproduces the stuck modal`, () => {
                const f = fixture(kind, true, nativeMethods);
                f.modal.containerEl.isConnected = true;
                f.scopes.push(f.modal.scope);
                f.modal.onOpen();
                f.modal.close();
                assert.equal(f.modal.isOpen, false);
                assert.equal(f.modal.containerEl.isConnected, true);
                assert.equal(f.scopes.length, 2);
                assert.equal(f.modal.baseCloseCount, undefined);
            });
        }
        for (const hotkey of [true, false]) {
            for (const route of ["click", "Enter", "Shift+Enter", "Alt+Enter", "Escape", "backdrop", "close button"]) {
                test(`${runtime}: ${kind}, hotkey=${hotkey}, ${route}`, () => {
                    const f = fixture(kind, hotkey, nativeMethods);
                    const m = f.modal;
                    m.open();
                    assert.equal(m.containerEl.isConnected, true);
                    assert.equal(f.scopes.length, 2);
                    assert.equal(f.closables.length, 2);
                    const evt = {
                        target: m.modalEl.querySelector(".prompt-input"),
                        shiftKey: route === "Shift+Enter",
                        altKey: route === "Alt+Enter",
                        preventDefault() {}, stopPropagation() {},
                        composedPath() { return [this.target]; },
                    };
                    if (route === "click") m.onSuggestionClick(evt, m.chooser.suggestions[1]);
                    else if (route === "backdrop") m.bgEl.listeners.click(evt);
                    else if (route === "close button") m.closeButton.listeners.click(evt);
                    else m.scope.bindings.get(route)(evt);
                    assert.equal(m.containerEl.isConnected, false);
                    assert.equal(m.baseCloseCount, 1);
                    assert.deepEqual(f.scopes, [f.parentScope]);
                    assert.deepEqual(f.closables, [f.parentModal]);
                    assert.equal(f.loads.length, route === "click" || route === "Enter" || route === "Alt+Enter" ? 1 : 0);
                    if (route === "Shift+Enter") assert.equal(f.saves.length, 1);
                    if (!hotkey) assert.equal(f.poppers[0].destroyed, 1);
                    m.close();
                    assert.equal(m.baseCloseCount, 1, "Repeated close must not pop the parent scope");
                    m.open();
                    m.close();
                    assert.equal(m.baseCloseCount, 2);
                    if (!hotkey) assert.equal(f.poppers[1].destroyed, 1);
                });
            }
            test(`${runtime}: ${kind}, hotkey=${hotkey}, Escape cancels rename first`, () => {
                const f = fixture(kind, hotkey, nativeMethods);
                f.modal.open();
                const target = new ElementStub();
                target.classList.contains = cls => cls === "workspace-item";
                target.contentEditable = "true";
                target.dataset = { workspaceName: "Alpha" };
                f.modal.onEscape({ target });
                assert.equal(target.contentEditable, "false");
                assert.equal(target.textContent, "Alpha");
                assert.equal(f.modal.containerEl.isConnected, true);
                f.modal.onEscape({ target });
                assert.equal(f.modal.containerEl.isConnected, false);
            });
        }
    }
}
