import requests
from bs4 import BeautifulSoup
import json
import time
import re
from urllib.parse import urljoin, urlparse

def is_article_link(url):
    """Check if the URL is likely an external article link"""
    
    # If it's an external link (not on longreads.com)
    parsed_url = urlparse(url)
    if parsed_url.netloc and 'longreads.com' not in parsed_url.netloc:
        # Filter out common non-article URLs
        excluded_domains = [
            'twitter.com', 'facebook.com', 'instagram.com', 
            'tumblr.com', 'google.com', 'automattic.com',
            'wordpress.com', 'mastodon.world', 'newspack.com',
            'cookiedatabase.org', 'x.com', 'bsky.app', 'bsky.social',
            'youtube.com', 'youtu.be', 'soundcloud.com', 'soundcloud.app.goo.gl',
            'amazon.com', 'fandom.com', 'tiktok.com', 'tiktok.com.vn'
        ]
        
        return not any(domain in parsed_url.netloc for domain in excluded_domains)
    
    return False

def is_list_page(url):
    """Check if the URL is likely a list page with articles"""
    
    if not url.startswith('http'):
        return False
    
    # Exclude certain patterns that are definitely not list pages
    excluded_patterns = [
        '/tag/', '/author/', '/about/', '/contact/', 
        '/feed/', '/newsletter/', '/privacy/', '/terms/',
        '/subscription/', '#', '.jpg', '.png', '.gif'
    ]
    
    for pattern in excluded_patterns:
        if pattern in url:
            return False
    
    # Include longreads.com URLs with patterns that suggest a list
    included_patterns = [
        '/best-of/', '/picks/', '/reading-lists/', 
        '/editors-picks/', '/best-of-20', '/features/'
    ]
    
    parsed_url = urlparse(url)
    if 'longreads.com' in parsed_url.netloc:
        for pattern in included_patterns:
            if pattern in url:
                return True
    
    return False

def get_subpages(url):
    """Get subpages from a yearly page"""
    try:
        print(f"Fetching subpages from: {url}")
        response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        subpages = []
        links = soup.find_all('a', href=True)
        
        for link in links:
            href = link['href']
            full_url = urljoin(url, href)
            
            if is_list_page(full_url) and full_url != url:
                subpages.append(full_url)
        
        # Remove duplicates
        subpages = list(set(subpages))
        print(f"  Found {len(subpages)} potential subpages")
        return subpages
        
    except Exception as e:
        print(f"  Error fetching subpages from {url}: {e}")
        return []

def extract_articles_from_page(url):
    """Extract article links from a page"""
    try:
        print(f"Extracting articles from: {url}")
        response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        article_links = []
        links = soup.find_all('a', href=True)
        
        for link in links:
            href = link['href']
            full_url = urljoin(url, href)
            
            if is_article_link(full_url):
                article_links.append(full_url)
        
        # Remove duplicates
        article_links = list(set(article_links))
        print(f"  Found {len(article_links)} article links")
        return article_links
        
    except Exception as e:
        print(f"  Error extracting articles from {url}: {e}")
        return []

def main():
    all_links = []
    all_pages_to_visit = []
    visited_pages = set()
    
    # Start with the main "Best of" pages for each year
    years = range(2011, 2025)  # 2011 to 2024
    base_url = "https://longreads.com/best-of-"
    
    for year in years:
        year_url = f"{base_url}{year}/"
        all_pages_to_visit.append(year_url)
    
    # Add the main "Best of" page as well
    all_pages_to_visit.append(base_url)
    
    # Process pages in a breadth-first manner
    while all_pages_to_visit:
        current_url = all_pages_to_visit.pop(0)
        
        if current_url in visited_pages:
            continue
            
        visited_pages.add(current_url)
        print(f"\nProcessing: {current_url}")
        
        # Get subpages first
        subpages = get_subpages(current_url)
        for subpage in subpages:
            if subpage not in visited_pages:
                all_pages_to_visit.append(subpage)
        
        # Extract article links
        articles = extract_articles_from_page(current_url)
        all_links.extend(articles)
        
        # Be nice to the server
        time.sleep(1)
    
    # Remove duplicates from final list
    all_links = list(set(all_links))
    print(f"\nTotal unique article links: {len(all_links)}")
    
    # Save to JSON file
    with open('/static/data/longreads_articles.json', 'w') as f:
        json.dump(all_links, f, indent=2)
    
    print(f"Links saved to static/data/longreads_articles.json")
    
    # Print sample of found articles for verification
    print("\nSample of found articles:")
    for link in all_links[:10]:
        print(f"- {link}")

if __name__ == "__main__":
    main()