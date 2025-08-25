window.addEventListener('message', function(event) {
    var data = event.data;
    
    switch(data.action) {
        case 'show':
            showAnimalStatus(data);
            break;
        case 'hide':
            hideAnimalStatus();
            break;
    }
});

function showAnimalStatus(data) {
    // Update animal type and gender
    document.getElementById('animal-type').textContent = data.animalType || 'UNKNOWN';
    document.getElementById('animal-gender').textContent = data.animalGender || 'Unknown';
    
    // Update health bar
    updateStatBar('health', data.health || 0, data.healthColor || getHealthColor(data.health || 0));
    
    // Update hunger bar
    updateStatBar('hunger', data.hunger || 0, data.hungerColor || getHungerColor(data.hunger || 0));
    
    // Update thirst bar
    updateStatBar('thirst', data.thirst || 0, data.thirstColor || getThirstColor(data.thirst || 0));
    
    // Update production status if shown
    if (data.showProduction) {
        document.getElementById('production-section').classList.remove('hidden');
        document.getElementById('production-status').textContent = data.productionStatus || 'Unknown';
        document.getElementById('production-status').style.color = data.productionColor || '#fff';
    } else {
        document.getElementById('production-section').classList.add('hidden');
    }
    
    // Show the status panel
    document.getElementById('animal-status').classList.remove('hidden');
}

function hideAnimalStatus() {
    document.getElementById('animal-status').classList.add('hidden');
}

function updateStatBar(stat, value, color) {
    const bar = document.getElementById(stat + '-bar');
    const valueElement = document.getElementById(stat + '-value');
    
    if (bar && valueElement) {
        bar.style.width = value + '%';
        bar.style.backgroundColor = color;
        valueElement.textContent = value + '%';
        valueElement.style.color = color;
    }
}

function getHealthColor(value) {
    if (value >= 80) return '#4CAF50'; // Green
    if (value >= 60) return '#FF9800'; // Orange
    if (value >= 30) return '#FF5722'; // Red-Orange
    return '#F44336'; // Red
}

function getHungerColor(value) {
    if (value >= 70) return '#4CAF50'; // Green
    if (value >= 40) return '#FF9800'; // Orange
    return '#F44336'; // Red
}

function getThirstColor(value) {
    if (value >= 70) return '#2196F3'; // Blue
    if (value >= 40) return '#FF9800'; // Orange
    return '#F44336'; // Red
}

// Register NUI callback for closing
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && !document.getElementById('animal-status').classList.contains('hidden')) {
        fetch('https://animal_farming/close', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        hideAnimalStatus();
    }
});

// Prevent context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Prevent selection
document.addEventListener('selectstart', function(event) {
    event.preventDefault();
});