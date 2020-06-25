# Query selects
The application uses theses css query selector to parse the html

- body > div.bulletin > table > tbody > tr
  - Student name: children[1].children[0].children[0].children[0].text
  - Student formation: children[1].children[0].children[0].children[1].text
  
- body > form > fieldset > p > select
  - Semesters list: iteration over children
 
- \#absences
  - If not null iteration over getElementsByTagName("tr")
    - a.from = el.getElementsByTagName("td")[0].text;
    - a.to = el.getElementsByTagName("td")[1].text;
    - a.justified = el.getElementsByTagName("td")[2].text == "Oui";
    - a.cause = el.getElementsByTagName("td")[3].text;

- semester.done = document.outerHtml.contains("Les informations contenues dans ce tableau sont définitives");

- .notes_bulletin
  - iteration over gradesTable.getElementsByTagName("tr")
  - If semester done:
    - UE: el.attributes["class"] != null && el.attributes["class"].contains("notes_bulletin_row_ue")
    - Classes
  - If semester not done:
    - UE: el.attributes["class"] != null && el.attributes["class"].contains("notes_bulletin_row_ue")
    - Grade: el.attributes["class"] != null && el.attributes["class"].contains("toggle4")
    - Classes

There are more details to this in the lib/DemoArenaUtils.dart file in the function parseUserFormHTML() (line 158-431) 