window.onload = init;

function init() {
    const $replOutput = document.getElementById('replOutput');
    const $cmdInput = document.getElementById('cmdInput')
    cmdInput.addEventListener('change', (e) => execute($cmdInput, $replOutput, e.target.value));
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
        method,
        body: parameter
    })
    .then(res => res.text())
    .then(text => appendToRepl($replOutput, text))
}