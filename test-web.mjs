import { SduiParser } from './shared/build/dist/js/developmentLibrary/shared.mjs';
const parser = new SduiParser();
const json = parser.getMockData();
const components = parser.parseAsArray(json);
console.log("Mock data parsed.");
const col = components[0].childrenArray[3];
console.log("Column style:");
console.log("Margin: ", col.style.margin);
console.log("Padding: ", col.style.padding);
