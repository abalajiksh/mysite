/*
    Original Author: Bramus Van Damme
    Link to original: https://www.bram.us/2020/01/10/smooth-scrolling-sticky-scrollspy-navigation/

    Most of this code comes courtesy of Bramus Van Damme, with some minor tweaks
    to get it working for my use case.  Thanks, Bramus!

    Site-level override of themes/poison/assets/js/toc.js (resolved first by
    Hugo's union filesystem, like copyblock.js). Only change from upstream: a
    null guard so the script no longer throws on pages that have no `.post`
    article element (topics, projects, series, tags, and other list pages).
    Without it, `document.querySelector(".post")` is null there and the next
    `.querySelectorAll` call raised "Cannot read properties of null".
*/

let activeElement = null;
window.addEventListener('DOMContentLoaded', () => {
    const post = document.querySelector(".post");
    if (!post) return; // no article on this page -> nothing to build a TOC from

    const observer = new IntersectionObserver(entries => {
        if (entries) {
            const contents = document.getElementById("contents");
            if (contents) {
                contents.innerHTML = "Contents";
            }
        }
        entries.forEach(entry => {
            if (activeElement) {
                document.querySelectorAll("nav[id='TableOfContents'] li").forEach((node) => {
                    node.classList.add('inactive');
                    node.classList.replace('active', 'inactive');
                });
            }
            if (entry.intersectionRatio > 0) {
                activeElement = entry.target.getAttribute('id');
            }
            if (activeElement) {
                const link = document.querySelector(`nav[id='TableOfContents'] li a[href="#${activeElement}"]`);
                if (link) {
                    link.parentElement.classList.replace('inactive', 'active');
                }
            }
        });
    });

    post.querySelectorAll("h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]").forEach((section) => {
        observer.observe(section);
    });
});
