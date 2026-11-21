# TEI Page Editor: Implementation Plan

## 1. Goal

Build a small, offline-first Windows web app for transcribing one manuscript page at a time into TEI P5 XML.

The app must:
- run locally on `127.0.0.1`;
- require no terminal knowledge;
- save one manuscript as one UTF-8 TEI-XML file;
- preserve text exactly, including combining characters and symbols;
- keep the TEI file useful when the app is unavailable;
- keep a small, local GitHub workflow through GitHub Desktop.

## 2. Fixed decisions

### 2.1 Runtime
- Python 3.11 or newer.
- Flask 3.x and lxml 5.x or 6.x: the only third-party packages.
- Plain HTML, CSS and vanilla JavaScript.
- No Node.js, framework, build step, database, CDN, analytics or runtime internet access.
- Windows is the supported platform.
- All packages are installed only in `tei_editor/.venv`.

### 2.2 Folder

The implementation may create or modify files only inside `tei_editor/`.

```text
tei_editor/
├── START-EDITOR.bat
├── README.md
├── requirements.txt
├── .gitignore
├── app/
│   ├── __init__.py
│   ├── app.py
│   ├── routes.py
│   ├── tei.py
│   ├── static/
│   │   ├── app.css
│   │   └── app.js
│   ├── templates/
│   └── schema/
├── tests/
├── data/
├── images/
├── backups/
├── characters.txt
└── .venv/
```

`data/` and `backups/` are repository data. `.venv/`, `__pycache__/`, test output and temporary XML files are excluded by Git.

Images are not stored in GitHub: `images/` is excluded from the repository. The TEI file stores a relative URL such as `images/MS123_f12r.jpg`.

### 2.3 Manuscripts
- There is one TEI-XML file per manuscript.
- Files live in `data/`.
- The filename is derived once from a shelfmark and folio. It is an editable form, for example `BAV_Vat_lat_1234_f12r.xml`.
- Shelfmark and folio remain separate fields in the manuscript header.
- `transcription.xml` is not used: the old single-file prototype must not be retained as a second format.
- No database or hidden transcription file is used.

## 3. TEI format

Use TEI P5:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <title>Transcription of Example Library, MS 123, fol. 12r</title>
        <respStmt>
          <resp>Transcribed by</resp>
          <persName>Example Transcriber</persName>
        </respStmt>
      </titleStmt>
      <publicationStmt>
        <p>Unpublished working transcription for personal research.</p>
      </publicationStmt>
      <sourceDesc>
        <msDesc>
          <msIdentifier>
            <settlement>Example City</settlement>
            <repository>Example Library</repository>
            <idno>MS 123</idno>
          </msIdentifier>
        </msDesc>
      </sourceDesc>
    </fileDesc>
  </teiHeader>
  <facsimile>
    <surface xml:id="surface-12r">
      <graphic url="images/MS123_f12r.jpg"/>
    </surface>
  </facsimile>
  <text>
    <body>
      <ab>
        <pb n="12r" facs="#surface-12r"/>
        <cb n="a"/>
        <lb n="1"/>Text of first line
        <lb n="2"/>
        <cb n="b"/>
        <lb n="1"/>
      </ab>
    </body>
  </text>
</TEI>
```

Fixed format rules:
- The body text is one `<ab>`.
- `<pb n="…"/>` identifies the page/folio.
- `<cb n="…"/>` identifies a column.
- `<lb n="…"/>` precedes every line and lives directly in `<ab>`.
- Empty lines have a bare `<lb/>` and no following text.
- Words continuing on the following line use `break="no"` on the following `<lb/>`.
- XML text is indented for a person to read, but one manuscript line must occupy one XML text node.
- lxml is used for all parsing, editing and serialization.
- Real Unicode characters are saved. XML escapes are only an output concern.
- Existing files may contain only the elements and attributes this app supports.

## 4. Data model

The browser may use a plain in-memory view model, but it must never be the only copy of scholarly data.

```text
Manuscript
- path
- city
- library
- shelfmark
- folio
- title
- transcriber
- transcription_date
- image
- columns
  - label
  - lines
    - n
    - text
```

The server owns the TEI file and performs all parsing and serialization. The browser never constructs XML.

## 5. Behaviour and acceptance checks

### Starting
1. Double-click `START-EDITOR.bat`.
2. It checks for Python 3.11+, creates `.venv` if absent, installs requirements if absent, starts the Flask app, and opens the default browser.
3. Errors remain visible in the window instead of disappearing.
4. The app listens only on `127.0.0.1`.
5. Closing the window stops the app.

### Manuscript list
1. The home page lists every supported TEI file in `data/`.
2. **New manuscript** collects city, library, shelfmark, folio, title, transcriber and start date.
3. A new manuscript begins with one column labelled `a` and 30 empty lines.
4. A title is suggested from the fields but remains editable.
5. Creating a duplicate refuses to overwrite and explains which file already exists.
6. An unsupported or malformed file is listed with a warning and cannot be opened.
7. Unsupported markup is identified in plain English and its file remains unchanged.

### Editing
1. Lines are numbered text boxes. Columns sit side by side.
2. Enter moves to the following line; Up and Down move between lines.
3. Add/remove line and column operations renumber in app data and XML.
4. Confirmation is required for removing text.
5. The last column cannot be removed.
6. Text is not trimmed or normalized; spaces and Unicode are preserved.
7. Character buttons insert text at the cursor.
8. Characters come from `characters.txt`, with one character followed optionally by a description.

### Markup
Markup is shown as visible tags, not as rich-text formatting.

The buttons support:
- abbreviation/expansion;
- addition, with place `above`, `below` or `margin`;
- deletion, with `rend="strikethrough"`;
- unclear;
- gap, with reason and approximate character quantity;
- word continuing on the next line.

Markup may not overlap or remain unclosed. The server rejects invalid markup and does not save it.

### Details and images
1. Details changes are autosaved to the TEI header.
2. The page image drop-down lists files in `images/`.
3. Selection records a relative URL in `<facsimile>`.
4. Missing images show a clear message while the transcription remains usable.
5. Zoom, fit and scroll controls do not disturb transcription editing.

### Saving and recovery
1. Typing is saved about one second after it stops.
2. Structural changes save immediately.
3. **Saving…** becomes **Saved at HH:MM:SS** on success.
4. Save failure shows **Not saved — reason**, keeps the in-memory text, and retries.
5. XML is generated in memory, parsed again and checked for well-formedness before replacement.
6. The server writes a temporary file beside the destination and atomically replaces the destination.
7. Exactly two backups per manuscript are kept: a backup on open and another at most every 10 minutes during a session.
8. A save is never silently omitted, and backups are the only automatically deleted files.

## 6. Safeguards and validation

### Supported-file opening
Opening a file must:
1. read it as UTF-8;
2. parse it with lxml;
3. verify the TEI namespace;
4. verify the exact supported structure;
5. reject unknown elements or attributes instead of silently dropping them;
6. preserve the file if a save would be unsafe.

### TEI check
**Check TEI** reports one of:
- `Well-formed and valid TEI`;
- `Well-formed but validity is not checked`;
- a plain list of well-formedness or validity problems.

The app has a built-in well-formedness check. Optional Relax NG validation uses `tei_all.rng` placed by the user in `app/schema/`; the app never downloads or changes it.

VS Code with the Red Hat XML extension is an independent visual check.

### Tests
Use `unittest` and temporary directories under `tests/`.

Automated tests must cover:
- new manuscript structure;
- line and column numbering;
- exact Unicode round trips;
- special characters `<`, `&` and combining marks;
- safe save and restore;
- malformed XML;
- unsupported markup;
- duplicate manuscript refusal;
- backup count;
- missing image;
- overlapping markup rejection;
- each supported markup element;
- Details header changes.

## 7. Build phases

Stop after every phase and wait for review.

### Phase 1 — App starts
- Create `tei_editor/`, launcher, virtual environment setup, requirements and offline Flask page.
- Check: launcher starts and stops cleanly; second start does not reinstall unnecessarily.

### Phase 2 — Manuscript management
- Create list, Details form and initial 30-line TEI file.
- Check: create and reload a test manuscript; XML is well formed.

### Phase 3 — Editing and autosave
- Add line editing, keyboard movement, safe save, status and exactly two backups.
- Check: text, Unicode and spaces survive reload; save failure is visible.

### Phase 4 — Structure
- Add and remove lines and columns.
- Check: numbering and XML stay in sync; destructive operations confirm.

### Phase 5 — Header, characters and markup
- Add Details form, character buttons and visible-tag markup.
- Check: each markup kind round-trips through lxml; invalid markup is refused.

### Phase 6 — Images and final validation
- Add image selection, zoom and built-in TEI check.
- Check: relative image URLs, missing-image handling and independent XML validation.

### Phase 7 — Documentation and user testing
- Complete README, recovery instructions and Windows-only setup.
- Check: every start, backup, and restore action is understandable without terminal use.

## 8. Working rules

1. Complete one phase at a time. After implementation and tests, stop and show the exact manual checks.
2. Use plain-English explanations for every setup and result.
3. Do not add packages or features beyond this plan.
4. Never modify files outside `tei_editor/`.
5. Never modify a user's `data/` or `images/` file during tests; use temporary test directories.
6. Never run Git commands or commit or push changes.
7. Never silently catch save, parsing or validation errors.
8. Never rewrite the XML with string concatenation or regular expressions.
9. Keep the README current with every change.
10. Ask before changing a fixed TEI element, attribute or behaviour.

## 9. Out of scope

- Multiple pages or page navigation.
- Multiple simultaneous manuscripts.
- OCR/HTR and external imports.
- PDF, Word or HTML export.
- Accounts or network access.
- Rich-text/tag-hidden editing.
- Image region linking.
- Notes, apparatus, variants or additional TEI markup.
- Mac and Linux support.
