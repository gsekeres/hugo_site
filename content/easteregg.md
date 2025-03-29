---
title: "Hi!"
layout: "easteregg"
url: "/easteregg/"
summary: "easter egg"
hidemeta: true
---

Hi! Thanks for clicking on me! I hope you enjoyed the experience. You have three options:

<style>
@keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-5px); }
}

.easter-button {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 20px !important;
    background-color: #f0f0f0 !important;
    color: var(--primary) !important;
    text-decoration: none !important;
    border-radius: 5px !important;
    flex: 1 !important;
    text-align: center !important;
    max-width: 250px !important;
    min-height: 70px !important;
    transition: all 0.2s ease !important;
    border: 1px solid var(--border) !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1) !important;
    margin: 0 !important;
    cursor: pointer !important;
}

.easter-button:hover {
    animation: bounce 0.5s ease infinite;
    background-color: #e0e0e0 !important;
}

.button-container {
    display: flex !important;
    justify-content: center !important;
    gap: 20px !important;
    margin-top: 20px !important;
    width: 100% !important;
}

@media screen and (max-width: 768px) {
    .button-container {
        flex-direction: column !important;
        align-items: center !important;
    }
    
    .easter-button {
        max-width: 80% !important;  /* Makes buttons wider on mobile */
    }
}
</style>

<script>
function openRandomLongreadsArticle() {
  console.log("Button clicked, attempting to fetch articles...");
  
  // Define the articles directly in the code as a fallback
  const fallbackArticles = [
    "https://longreads.com/2022/10/25/the-last-days-of-the-dinosaurs/",
    "https://longreads.com/2022/09/27/the-long-shot/",
    "https://longreads.com/2022/08/30/the-art-of-losing-friends/",
    "https://longreads.com/2022/07/26/the-last-resort/",
    "https://longreads.com/2022/06/28/the-big-lie/",
    "https://www.newyorker.com/magazine/2023/02/06/the-myth-of-normal-family",
    "https://www.theatlantic.com/magazine/archive/2022/05/social-media-democracy-trust-babel/629369/",
    "https://www.nytimes.com/2022/04/13/magazine/tennis-ball-manufacturing.html",
    "https://www.wired.com/story/ai-prompt-engineering-jobs/"
  ];
  
  // Create a function to open the article
  const openArticle = (article) => {
    console.log("Opening article:", article);
    
    // For Safari compatibility, use location.href instead of window.open
    // but first check if we should open in a new tab
    const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    
    if (isIOS) {
      // For iOS Safari, we'll use window.location directly
      // First create a visible notification that we're redirecting
      const notification = document.createElement('div');
      notification.style.position = 'fixed';
      notification.style.top = '50%';
      notification.style.left = '50%';
      notification.style.transform = 'translate(-50%, -50%)';
      notification.style.padding = '20px';
      notification.style.backgroundColor = 'rgba(0,0,0,0.8)';
      notification.style.color = 'white';
      notification.style.borderRadius = '10px';
      notification.style.zIndex = '9999';
      notification.textContent = 'Opening article...';
      document.body.appendChild(notification);
      
      // Then redirect after a short delay
      setTimeout(() => {
        window.location.href = article;
      }, 500);
    } else if (isSafari) {
      // For desktop Safari, create and click a temporary link
      const tempLink = document.createElement('a');
      tempLink.href = article;
      tempLink.target = '_blank';
      tempLink.rel = 'noopener noreferrer';
      tempLink.style.display = 'none';
      document.body.appendChild(tempLink);
      tempLink.click();
      document.body.removeChild(tempLink);
    } else {
      // For other browsers, use window.open
      window.open(article, '_blank', 'noopener,noreferrer');
    }
  };
  
  // Try to fetch the JSON file
  fetch('/data/longreads_articles.json')
    .then(response => {
      console.log("Fetch response status:", response.status);
      if (!response.ok) {
        throw new Error(`Failed to load article list (status ${response.status})`);
      }
      return response.json();
    })
    .then(articles => {
      console.log("Articles loaded:", articles);
      if (!Array.isArray(articles) || articles.length === 0) {
        throw new Error('No articles found or invalid format');
      }
      
      // Select a random article from the list
      const randomIndex = Math.floor(Math.random() * articles.length);
      const randomArticle = articles[randomIndex];
      
      // Open the article
      openArticle(randomArticle);
    })
    .catch(error => {
      console.error('Error loading random article:', error);
      
      // Use a fallback article from the hardcoded list
      const randomIndex = Math.floor(Math.random() * fallbackArticles.length);
      const randomArticle = fallbackArticles[randomIndex];
      console.log("Using fallback article:", randomArticle);
      
      // Open the fallback article
      openArticle(randomArticle);
    });
}
</script>

<div class="button-container">
    <a href="/" class="easter-button">Return Home</a>
    <a href="https://longform.org/random" class="easter-button">Read a Random Article</a>
    <a href="https://zoo.sandiegozoo.org/cams/ape-cam" class="easter-button">Ape Cam</a>
</div>

<div style="text-align: center;">
    <h2>Choose wisely! Enjoy some birds while you're here.</h2>
</div>
    <div style="display: flex; justify-content: center;">
        <iframe 
            width="600" 
            height="337" 
            src="https://www.youtube.com/embed/x10vL6_47Dw?autoplay=1&mute=1&playsinline=1" 
            frameborder="0" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen>
        </iframe>
    </div>


## The Random Article Button

At some point in March 2025, my favorite button on the entire internet, the "Get a Random Article" button on the [longform.org](https://longform.org/) website, stopped working. I started panicking, and tried to recreate it for my own usage. In order to even slightly approximate that feature, I scraped the [longreads.com](https://longreads.com/) website to compile a list of approximately 500 articles from their year-end lists. 

Then, three days later, [longform.org](https://longform.org/) was back again, with my favorite button working as expected. I have no idea what happened, but my (shoddy) work still exists. The main button above again links to [longform.org/random](https://longform.org/random), but the button below is my own implementation. 

The code to do everything is [in the repo](https://github.com/gsekeres/hugo_site), in the `scraper.py` file and the `content/easteregg.md` file. I plan on updating this with newer articles when I remember to do so, so it might serve as a random new article button? Stay tuned.

<div class="button-container">
      <button onclick="openRandomLongreadsArticle()" class="easter-button">Read A Random Article: Gabe's Version</button>
</div>



