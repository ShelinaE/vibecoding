# TEI Page Editor: Build Plan

## Goal

Build a small web app that runs on my own laptop and lets me transcribe one manuscript page into TEI-XML. I type in the browser, and the app saves my work to a TEI file automatically.

## Who it's for

I am a medievalist with no coding experience. Setting up and running the app must take as few steps as possible, and everything you do must be explained to me in plain English.

## Technical decisions (do not deviate)

- Python 3.11 or newer, with **Flask** as the only third-party package. Pin the exact Flask version used in `requirements.txt`. Use the standard library (`xml.etree.ElementTree`) for XML. Ask me before adding any other package.
- Plain HTML, CSS, and vanilla JavaScript. No JavaScript frameworks, no build tools, no database, no accounts, no API keys, and no internet connection needed at runtime.
- Put everything inside a folder called `tei_editor/`. Do not create or modify anything outside it.
- Use a virtual environment at `tei_editor/.venv`, with dependencies pinned in `requirements.txt`.
- The server must listen on `127.0.0.1` only, so that nobody else on the network can reach it.
- Save the data to `tei_editor/data/transcription.xml`, encoded as UTF-8.
- The first setup may need internet access once to install Flask. After setup, starting and using the app must work without an internet connection and must not contact an external service.

## Behaviour

1. On first launch, the editor shows one page with one column of 30 empty, numbered lines.
2. Each line is a single-line text box. Columns sit side by side and are labelled a, b, c, and so on.
3. I can add and remove lines (within a column) and add and remove columns. Line numbers update automatically and restart at 1 in each column. Ask for confirmation before removing a line or column that contains non-whitespace text. Cancelling leaves the editor unchanged. Always keep at least one column and one line; prevent removing the last one rather than allowing an invalid state.
4. **Autosave:** save about one second after I stop typing, and immediately after any confirmed structural change. Show a saving indicator while a save is in progress, then show "Saved at HH:MM:SS" using the computer's local time. If saving fails, show a clear error message and keep the text in the editor so it can be saved again. Never fail silently.
5. Before each save, copy the previous `transcription.xml` to `transcription.xml.bak`. This is one rolling backup of the immediately previous file; the first save has no previous file to back up. If the backup cannot be made, do not overwrite the transcription, and show an error.
6. On startup, load `transcription.xml` if it exists, so my work carries over between sessions. If it is missing, start with one column and 30 empty lines. If an existing file cannot be parsed or loaded, show a clear error and preserve it; do not silently start blank or overwrite it.
7. Keep my text exactly as typed, apart from trimming leading and trailing spaces on each line when saving. Characters such as `<`, `>`, `&`, accented letters, and combining or medieval characters must survive saving and reloading unchanged. Never normalise Unicode. XML special characters must be escaped in the XML file and restored as the original characters when loaded.
8. If I try to close or leave the page while edits are waiting to be saved, warn me and let me stay on the page to wait for the save. Do not promise that a save can finish if I force-close the browser or shut down the computer.

## TEI output

Use this structure. Each `<lb/>` goes on its own line, with the line's text immediately after it.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
  <teiHeader>
    <fileDesc>
      <titleStmt><title>Untitled transcription</title></titleStmt>
      <publicationStmt><p>Unpublished</p></publicationStmt>
      <sourceDesc><p>Born-digital transcription</p></sourceDesc>
    </fileDesc>
  </teiHeader>
  <text>
    <body>
      <div>
        <p>
          <pb n="1"/>
          <cb n="a"/>
          <lb n="1"/>First line of column a
          <lb n="2"/>Second line of column a
          <cb n="b"/>
          <lb n="1"/>First line of column b
        </p>
      </div>
    </body>
  </text>
</TEI>
```

Empty lines still get an `<lb n="…"/>` element. If you are unsure whether any markup is valid TEI, tell me rather than guessing.

## Build phases

Work through the phases in order. **Stop at the end of each phase** and wait for me.

**Phase 1: Setup and "hello world"**
Create `tei_editor/` with a virtual environment, `requirements.txt` (Flask only, with an exact version pin), a `.gitignore` (excluding `.venv/`, `__pycache__/`, and `*.bak`), and a minimal `app.py` that shows a page saying "TEI editor is running". Add a start script that I run by double-clicking: `start.bat` (Windows) and `start.command` (macOS, made executable). Each script must work from any starting location by first changing to its own folder. It must find and check Python 3.11 or newer using the platform's available Python launcher, and explain in plain English how to install a suitable Python version if none is found. On first run it creates `.venv` and installs the pinned requirement; explain that this first install may need internet access. Later starts must not need internet. It starts the app on `127.0.0.1:5001` (not port 5000), opens the local page in my browser after the server is ready, and if anything fails it keeps the window open so I can read the message. Write a short `README.md` with separate, step-by-step double-click instructions for Windows and macOS. It must not require me to type terminal commands.
*My check: I double-click the start script for my computer and see the page in my browser. The app is available only on my own computer.*

**Phase 2: The page layout**
Show one column labelled `a` with 30 empty, numbered, editable, single-line text boxes. Do not save yet.
*My check: I can type in every line, see line numbers 1 to 30, and read the page comfortably.*

**Phase 3: Saving to TEI**
Add autosave, TEI generation, the rolling backup, the on-screen save status, and loading on startup. Keep this phase to the initial single column; add structural editing in Phase 4. Also write `check_tei.py` and a double-clickable `check.bat` / `check.command` that runs it using the app's virtual environment, shows the result in plain English, and waits for a key press. It reports whether `data/transcription.xml` is well-formed XML. If parsing fails, report that clearly and do not claim structural checks passed. For well-formed XML, check the TEI namespace and report each structural problem: there is exactly one `<pb/>`; there is at least one `<cb/>`; every `<cb/>` and `<lb/>` is inside the expected `<p>`; columns are labelled `a`, `b`, `c`, and so on in order; and each column's lines are numbered `1`, `2`, `3`, and so on without gaps or repeats. Finally, print the number of `<pb/>`, `<cb/>`, and `<lb/>` elements and the number of lines in each column. State in the README that this checks XML well-formedness and the listed structure, not validity against a TEI schema.
*My check: I type text, open the XML file in VS Code, double-click the checker, read its result, and restart the app to confirm my text is still there.*

**Phase 4: Editing the structure**
Add and remove lines within a column and add and remove columns, with the confirmations and minimum counts specified above. After a confirmed change, renumber lines and columns as needed and save immediately. Cancelling a removal must not change the page or save a changed structure.
*My check: I add and remove lines and columns, try both confirming and cancelling a non-empty removal, and check that `check_tei.py` reports the same columns and line counts I see on screen.*

**Phase 5: Robustness**
Test the edge cases: empty and whitespace-only lines; `<`, `>`, and `&`; accented, combining, and medieval characters; very long lines; rapid typing; save and backup failures; malformed existing XML; cancelling a removal; attempting to remove the last column or line; and leaving the page while a save is pending. Confirm that a malformed existing file is preserved and that all errors are visible. Update `README.md` so a non-programmer can start the app, understand the save status and backup, run the checker by double-clicking, and resolve the expected setup and error messages.
*My check: I try the listed cases, restart the app, confirm that saved text is still present, and verify that no failure is hidden. I understand that force-closing the browser or computer before a pending save finishes can lose the latest edits.*

## Working rules for the agent

- Complete one phase at a time and stop at the end of each.
- Run all necessary terminal commands yourself; do not ask me to use the terminal or assume that I know how.
- At each stop, tell me in plain English which files you changed and why, how I can run and test the result without typing commands, what you tested yourself, and any choice you made on my behalf. Remind me to review the changes and commit them in GitHub Desktop before we continue.
- Do not add features, files, or packages that are not in this plan. Ask first.
- If anything in this plan is ambiguous or contradictory, ask me instead of guessing.
- Write simple, readable code with comments aimed at a non-programmer, in small functions.
- Never catch an error and hide it. Report it visibly in the app or the double-clicked script, and do not report a save as successful unless it completed.
- Never delete or overwrite my transcription without keeping a backup.
- Do not commit or push to Git. I will do that myself in GitHub Desktop.
- Before running any terminal command, explain in plain English what it does.

## Out of scope (for now)

Multiple pages and page navigation, displaying a facsimile image, editing the TEI header, schema validation, other export formats, user accounts, and putting the app online.