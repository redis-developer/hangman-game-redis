const wordDisplay = document.querySelector(".word-display");
const guessesText = document.querySelector(".guesses-text b");
const keyboardDiv = document.querySelector(".keyboard");
const hangmanImage = document.querySelector(".hangman-box img");
const gameModal = document.querySelector(".game-modal");
const playAgainBtn = gameModal.querySelector("button");

// Initializing game variables
let gameStartTime;
let currentWord, correctLetters, wrongGuessCount;
const maxGuesses = 6;

let playerName = "";
let words = [];
let usedWords = [];

const updatePlayerNameDisplay = () => {
    const playerNameDisplay = document.getElementById("player-name-display");
    if (playerNameDisplay) {
        playerNameDisplay.textContent = playerName || "anonymous";
    }
}

function fetchWords() {
    return fetch(getWordsAPI(), {
        method: 'POST', headers: {
            'Content-Type': 'application/json'
        }
    })
        .then(response => response.json())
        .then(data => {
            words = data;
            usedWords = [];
            console.log("Fetched new words from the API.");
        })
        .catch(error => {
            console.error('Error fetching words:', error);
        });
}

function selectWord() {
    if (usedWords.length === words.length) {
        usedWords = [];
        console.log("All words have been used. Resetting the list.");
    }

    let word, hint;
    do {
        const randomIndex = Math.floor(Math.random() * words.length);
        ({word, hint} = words[randomIndex]);
    } while (usedWords.includes(word));

    usedWords.push(word);
    currentWord = word;
    document.querySelector(".hint-text b").innerText = hint;
    resetGame();
}

const getRandomWord = () => {
    if (words.length === 0 || usedWords.length === words.length) {
        fetchWords().then(() => {
            selectWord();
        });
    } else {
        selectWord();
    }

    if (sessionStorage) {
        playerName = sessionStorage.getItem("playerName");
        updatePlayerNameDisplay();
    }

    if (playerName != null && playerName.length > 0) {
        resetGame();
    } else {
        showNameModal();
    }
}

const resetGame = () => {
    correctLetters = [];
    wrongGuessCount = 0;
    hangmanImage.src = "images/hangman-0.svg";
    guessesText.innerText = `${wrongGuessCount} / ${maxGuesses}`;
    wordDisplay.innerHTML = currentWord.split("").map(() => `<li class="letter"></li>`).join("");
    keyboardDiv.querySelectorAll("button").forEach(btn => btn.disabled = false);
    gameModal.classList.remove("show");
    gameStartTime = Date.now()
}

const gameOver = (isVictory) => {
    const modalText = isVictory ? `You found the word:` : 'The correct word was:';
    gameModal.querySelector("img").src = `images/${isVictory ? 'victory' : 'lost'}.gif`;
    gameModal.querySelector("h4").innerText = isVictory ? 'Congrats!' : 'Game Over!';
    gameModal.querySelector("p").innerHTML = `${modalText} <b>${currentWord}</b>`;
    gameModal.focus();
    gameModal.classList.add("show");
    sendGameData(isVictory);
}

document.addEventListener('DOMContentLoaded', () => {
    const gameModal = document.querySelector('.game-modal');
    const playAgainBtn = document.querySelector('.play-again');

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && gameModal.classList.contains('show')) {
            e.preventDefault();
            playAgainBtn.click();
        }
    });

});

function sendGameData(isVictory) {
    const gameEndTime = Date.now();
    let duration = (gameEndTime - gameStartTime) / 1000;
    duration = Math.min(Math.round(duration / 10) * 10, 70);
    duration = Math.floor(duration); // Make sure is an integer

    let guessAttempt = 1.0
    if (wrongGuessCount > 0) {
        guessAttempt = 1.0 - (wrongGuessCount / maxGuesses);
    }

    const gameData = {
        player_name: playerName,
        word: currentWord,
        score: isVictory ? 1 : 0,
        duration: duration,
        guess_attempt: guessAttempt
    };

    fetch(getGameAPI(), {
        method: 'POST', headers: {
            'Content-Type': 'application/json',
        }, body: JSON.stringify(gameData),
    })
        .then(response => response.json())
        .then(data => console.log(data))
        .catch((error) => {
            console.error('Error:', error);
        });
}

const initGame = (button, clickedLetter) => {
    // Checking if clickedLetter is exist on the currentWord
    if (currentWord.includes(clickedLetter)) {
        // Showing all correct letters on the word display
        [...currentWord].forEach((letter, index) => {
            if (letter === clickedLetter) {
                correctLetters.push(letter);
                wordDisplay.querySelectorAll("li")[index].innerText = letter;
                wordDisplay.querySelectorAll("li")[index].classList.add("guessed");
            }
        });
    } else {
        // If clicked letter doesn't exist then update the wrongGuessCount and hangman image
        wrongGuessCount++;
        hangmanImage.src = `images/hangman-${wrongGuessCount}.svg`;
    }
    button.disabled = true; // Disabling the clicked button so user can't click again
    guessesText.innerText = `${wrongGuessCount} / ${maxGuesses}`;

    // Calling gameOver function if any of these condition meets
    if (wrongGuessCount === maxGuesses) return gameOver(false);
    if (correctLetters.length === currentWord.length) return gameOver(true);
}

// Creating keyboard buttons and adding event listeners
for (let i = 97; i <= 122; i++) {
    const button = document.createElement("button");
    button.innerText = String.fromCharCode(i);
    keyboardDiv.appendChild(button);
    button.addEventListener("click", (e) => initGame(e.target, String.fromCharCode(i)));
}

// Add keyboard event listener
document.addEventListener("keydown", (event) => {
    const nameModal = document.querySelector('.name-modal');
    const isNameModalShown = window.getComputedStyle(nameModal).display === 'flex';
    const scoreboardModal = document.getElementById('scoreboard-modal');
    const isScoreboardModalShown = scoreboardModal.classList.contains('show');
    const metricsModal = document.getElementById('metrics-modal');
    const isMetricsModalShown = metricsModal.classList.contains('show');
    const isGameModalShown = gameModal.classList.contains('show');
    if (!event.shiftKey &&
        !isNameModalShown && !isGameModalShown && !isScoreboardModalShown && !isMetricsModalShown) {
        const key = event.key.toLowerCase();
        // Check if the pressed key is a lowercase letter (a-z)
        if (key >= 'a' && key <= 'z') {
            const button = Array.from(keyboardDiv.children).find(btn => btn.innerText.toLowerCase() === key);
            if (button && !button.disabled) {
                initGame(button, key);
            }
        }
    }
});

// Function to show the name modal
const showNameModal = () => {
    const scoreboardModal = document.getElementById('scoreboard-modal');
    const isScoreboardModalShown = scoreboardModal.classList.contains('show');
    const metricsModal = document.getElementById('metrics-modal');
    const isMetricsModalShown = metricsModal.classList.contains('show');
    const isGameModalShown = gameModal.classList.contains('show');

    if (isGameModalShown || isScoreboardModalShown || isMetricsModalShown) {
        return;
    }

    const nameModal = document.querySelector(".name-modal");
    const playerNameInput = document.getElementById('player-name');

    if (sessionStorage) {
        playerName = sessionStorage.getItem("playerName") || "";
    }

    playerNameInput.value = playerName;
    nameModal.style.display = "flex";
    playerNameInput.focus();
}

// Function to hide the name modal
const hideNameModal = () => {
    const playerNameDisplay = document.getElementById("player-name-display");
    if (playerNameDisplay) {
        playerNameDisplay.style.cursor = 'pointer'; // Make it look clickable
        playerNameDisplay.addEventListener('click', showNameChangeModal);
    }
    document.querySelector(".name-modal").style.display = "none";
}

// Function to handle name submission
const handleNameSubmit = () => {
    const nameInput = document.getElementById("player-name");
    const newName = nameInput.value.trim().replace(/\s+/g, '_');

    if (newName.length > 20) {
        alert("Choose a name with up to 20 characters.");
        return;
    }

    if (!newName) {
        alert("Specifying the player's name is mandatory.");
        return;
    }

    if (newName && newName !== playerName) {
        playerName = newName;
        updatePlayerNameDisplay();
        if (sessionStorage) {
            sessionStorage.setItem("playerName", playerName);
            fetch(getPlayerAPI(), {
                method: 'POST', headers: {
                    'Content-Type': 'application/json',
                }, body: JSON.stringify({player_name: playerName}),
            })
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                })
                .catch((error) => {
                    console.error('Error:', error);
                });
        }
    }
    hideNameModal();
    playAgainBtn.addEventListener("click", getRandomWord);
}

function cancelNameModal() {
    const nameModal = document.querySelector(".name-modal");
    nameModal.style.display = "none";
}

// Event listener for the confirm button
document.getElementById("confirm-name").addEventListener("click", handleNameSubmit);

document.addEventListener('DOMContentLoaded', function () {
    const playerNameInput = document.getElementById('player-name');
    const confirmNameButton = document.getElementById('confirm-name');

    playerNameInput.addEventListener('keyup', function (event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            confirmNameButton.click();
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            const nameInput = document.getElementById("player-name");
            if (!nameInput.value.trim()) {
                alert("Please enter your name.");
                return;
            }
            cancelNameModal();
        }
    });

    const playerNameDisplay = document.getElementById("player-name-display");
    if (playerNameDisplay) {
        playerNameDisplay.style.cursor = 'pointer'; // Make it look clickable
        playerNameDisplay.addEventListener('click', showNameChangeModal);
    }
});

// Show the name modal when the page loads
window.addEventListener("load", showNameModal);

function showScoreboardModal() {
    const nameModal = document.querySelector(".name-modal");
    const metricsModal = document.getElementById('metrics-modal');
    const isNameModalShown = window.getComputedStyle(nameModal).display === 'flex';
    const isMetricsModalShown = metricsModal.classList.contains('show');
    const isGameModalShown = gameModal.classList.contains('show');

    if (isNameModalShown || isMetricsModalShown || isGameModalShown) {
        return;
    }

    const scoreboardModal = document.getElementById('scoreboard-modal');
    scoreboardModal.classList.add('show');
    document.body.style.backgroundColor = 'rgba(0,0,0,0.4)';
    document.body.style.overflow = 'hidden';
}

function showMetricsModal() {
    const nameModal = document.querySelector(".name-modal");
    const scoreboardModal = document.getElementById('scoreboard-modal');
    const isNameModalShown = window.getComputedStyle(nameModal).display === 'flex';
    const isScoreboardModalShown = scoreboardModal.classList.contains('show');
    const isGameModalShown = gameModal.classList.contains('show');

    if (isNameModalShown || isScoreboardModalShown || isGameModalShown) {
        return;
    }

    const metricsModal = document.getElementById('metrics-modal');
    metricsModal.classList.add('show');
    document.body.style.backgroundColor = 'rgba(0,0,0,0.4)';
    document.body.style.overflow = 'hidden';
}

function hideScoreboardModal() {
    const scoreboardModal = document.getElementById('scoreboard-modal');
    scoreboardModal.classList.remove('show');
    document.body.style.backgroundColor = '';
    document.body.style.overflow = '';
}

function hideMetricsModal() {
    const metricsModal = document.getElementById('metrics-modal');
    metricsModal.classList.remove('show');
    document.body.style.backgroundColor = '';
    document.body.style.overflow = '';
}

function showNameChangeModal() {
    showNameModal();
}

// Event listener for keydown events
document.addEventListener('keydown', function (event) {
    if (event.shiftKey && (event.key === 's' || event.key === 'S')) {
        showScoreboardModal();
    } else if (event.shiftKey && (event.key === 'm' || event.key === 'M')) {
        showMetricsModal();
    } else if (event.shiftKey && (event.key === 'p' || event.key === 'P')) {
        event.preventDefault();
        showNameChangeModal();
    } else if (event.key === 'Escape') {
        cancelNameModal();
        hideScoreboardModal();
        hideMetricsModal();
    }
});

function setupPoller() {
    updateGameState();
    setInterval(updateGameState, 5000);
}

function updateGameState() {
    fetch(getMetricsAPI(), {
        method: 'POST', headers: {
            'Content-Type': 'application/json',
        }, body: JSON.stringify({}),
    })
        .then(response => response.json())
        .then(data => {
            updateScoreboard(data.scoreboard);
            updateGuessCount(data.guess_count);
            updateDurationCount(data.duration_count);
            updateFailedWords(data.failed_words)
        })
        .catch((error) => {
            console.error('Error:', error);
        });
}

function updateScoreboard(scoreboard) {
    const tbody = document.querySelector("#scoreboard-table tbody");
    tbody.innerHTML = "";

    scoreboard.forEach((entry, index) => {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td class="rank-column" style="text-align: center;">${index + 1}</td>
            <td>${entry.player_name}</td>
            <td class="score-column" style="text-align: center;">${entry.score}</td>
        `;
        tbody.appendChild(row);
    });
}

function updateGuessCount(guessCount) {
    const guessAttemptsTable = document.querySelector(".metrics-container #guess-attempts-table tbody");
    guessAttemptsTable.innerHTML = "";

    guessCount.forEach(guessCountItem => {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td>${guessCountItem.guess_attempt}</td>
            <td class="count-column" style="text-align: center;">${guessCountItem.count}</td>
        `;
        guessAttemptsTable.appendChild(row);
    });
}

function updateDurationCount(durationCount) {
    const durationCountTable = document.querySelector(".metrics-container #duration-count-table tbody");
    durationCountTable.innerHTML = "";

    durationCount.forEach(durationCountItem => {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td>${durationCountItem.duration}</td>
            <td class="count-column" style="text-align: center;">${durationCountItem.count}</td>
        `;
        durationCountTable.appendChild(row);
    });
}

function updateFailedWords(failedWords) {
    const failedWordsTable = document.querySelector(".metrics-container #failed-words-table tbody");
    failedWordsTable.innerHTML = "";

    failedWords.forEach(failedWordItem => {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td>${failedWordItem.word}</td>
            <td class="count-column" style="text-align: center;">${failedWordItem.count}</td>
        `;
        failedWordsTable.appendChild(row);
    });
}

window.addEventListener("load", () => {
    showNameModal();
    setupPoller();
});

getRandomWord();
playAgainBtn.addEventListener("click", getRandomWord);