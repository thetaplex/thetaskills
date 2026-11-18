# Slide patterns

How codebase-to-course's screens and interactive elements become slides. Slides are separated by a line holding only `---`. A slide's class goes on the line above its heading: `<!-- _class: part -->`.

## Slide classes in the template

| Class | Use it for | Look |
|---|---|---|
| `lead` | Title slide and closing slide | Parchment with a gold glow, centred |
| `part` | One divider per part: `# N · Part title` and one sentence | Near-black with a gold top rule |
| `faq` | The FAQ slide at the end of each part | Bronze headings and questions |
| `small` | Any slide that the render script reports as over 100% full | Smaller body text |
| none | Everything else | Parchment, serif headings, Inter body |

Combine two classes with a space: `<!-- _class: faq small -->`.

## From course elements to slides

| Course element | On a slide |
|---|---|
| Code ↔ English translation | A code block of the exact lines, then 2 to 4 bullets in plain English. Name the file in the heading: `## Title: \`path/file.py\`` |
| Quiz question | An FAQ entry: the scenario as a bold question, then the answer with its reasoning, including why the tempting wrong option is wrong |
| Drag-and-drop matching | A two-column table: item, and where it belongs. Place it in that part's FAQ slide |
| Group chat | A blockquote, one line per message: `> ⚙️ **Engine:** message` |
| Data-flow animation | A numbered list, one step per item, naming the actor in bold |
| Pattern or feature cards | A table with one column per card: an emoji and a title in the header, one line in the cell |
| File tree | A two-column table: folder, its one job |
| Callout | A blockquote that starts with 💡 (insight) or ⚠️ (common mistake) |
| Glossary tooltip | **Bold** the term on first use and define it in the same sentence. List the terms on the closing slide under "Your new vocabulary" |

## Density

- At most about 12 lines of code on a slide. Pick a short, contiguous run of lines from the file. Split a longer one over two slides, and never edit it to make it shorter.
- At most 4 bullets, or one table, under a code block.
- At most 3 questions on an FAQ slide. Use a second "FAQ · Part N (continued)" slide for more.
- The render script is the judge: a slide fits when it isn't reported over 100%.
