---
title: "Private Materials" 
date: 2024-12-09
lastmod: 2024-12-09
tags: []
author: ["Gabriel Sekeres"]
description: "Private materials." 
summary: "Private materials." 
---

## Access Restricted

This section contains private materials. To access these materials, you will need to enter the password provided by the author.

<div id="passwordForm">
  <form onsubmit="checkPassword(); return false;" style="display: flex; align-items: center;">
    <label for="password">Password:</label>
    <input type="password" id="password" name="password" required 
           style="margin-right: 10px; padding: 8px; border: 1px solid var(--border); border-radius: 4px; background-color: var(--entry);">
    <button type="submit" class="easter-button" style="padding: 10px 15px; min-height: auto; max-width: 100px;">Submit</button>
  </form>
  <p id="errorMessage" style="color: red; display: none;">Not the correct password</p>
</div>

<style>
@keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-5px); }
}

.easter-button {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    background-color: #f0f0f0 !important;
    color: var(--primary) !important;
    text-decoration: none !important;
    border-radius: 5px !important;
    transition: all 0.2s ease !important;
    border: 1px solid var(--border) !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1) !important;
    margin: 0 !important;
}

.easter-button:hover {
    animation: bounce 0.5s ease infinite;
    background-color: #e0e0e0 !important;
}
</style>

<div id="privateContent" style="display: none;">
  <!-- Your private content goes here -->
  [Private content will be shown here once I add it.]
</div>

<script>
function checkPassword() {
    var password = document.getElementById('password').value;
    var errorMessage = document.getElementById('errorMessage');
    var privateContent = document.getElementById('privateContent');
    var passwordForm = document.getElementById('passwordForm');
    
    if (password === 'urishall') {
        errorMessage.style.display = 'none';
        passwordForm.style.display = 'none';
        privateContent.style.display = 'block';
    } else {
        errorMessage.style.display = 'block';
        privateContent.style.display = 'none';
    }
}
</script>

<br><br>


If you are a Cornell student, SIEPR predoc, Stanford student, or a friend of a friend, please [email me](mailto:gs754@cornell.edu) to request the password.