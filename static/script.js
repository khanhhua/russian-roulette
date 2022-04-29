window.onload = init;

function init() {
    const $replOutput = document.getElementById('repl-output');
    const $cmdInput = document.getElementById('cmd-input')

    $cmdInput.addEventListener('change', (e) => execute($cmdInput, $replOutput, e.target.value));
}

function appendToRepl($replOutput, text) {
    const child = document.createElement('p');
    child.textContent = text;
    $replOutput.appendChild(child);
}

function execute($cmdInput, $replOutput, cmd) {
    appendToRepl($replOutput, cmd);

    $cmdInput.value = ''

    const [method, parameter] = cmd.split(' ');
    fetch('/', {
        method: method.toUpperCase(),
        body: parameter
    })
    .then(res => res.text())
    .then(text => appendToRepl($replOutput, text))
}