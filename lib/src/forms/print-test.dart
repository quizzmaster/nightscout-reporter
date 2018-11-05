import 'package:nightscout_reporter/src/jsonData.dart';

import 'base-print.dart';

class PrintTest extends BasePrint
{
  @override
  String id = "test";

  static bool showEntries = false;
  static bool showTreatments = true;

  @override
  List<ParamInfo> params = [
      ParamInfo("Einträge", boolValue: showEntries),
      ParamInfo("Behandlungen", boolValue: showTreatments),
    ];

  @override
  prepareData_(ReportData data)
  {
    showEntries = params[0].boolValue;
    showTreatments = params[1].boolValue;
    return data;
  }

  @override
  bool get isDebugOnly
  => true;

  @override
  String get name
  => "Ausgabe der Datensätze";
  @override
  String get title
  => "Datensätze";

  PrintTest()
  {
    init();
  }

  createRoot(type, body)
  {
    String color = "#eee";
    switch (type)
    {
      case "entries":
        body.add([
          {"text": "Uhrzeit", "fillColor": color},
          {"text": "Art", "fillColor": color},
          {"text": "sgv", "fillColor": color},
          {"text": "gluc", "fillColor": color},
        ]);
        break;
      case "treatments":
        body.add([
          {"text": "Uhrzeit", "fillColor": color},
          {"text": "Art", "fillColor": color},
          {"text": "Anpassung", "fillColor": color},
          {"text": "Dauer", "fillColor": color},
          {"text": "KH", "fillColor": color},
        ]);
        break;
    }

    var widths = [];
    for (int i = 0; i < body[0].length; i++)
      widths.add("auto");
    var ret = {
      "margin": [cmx(2.0), cmy(2.8), cmx(2.0), cmy(0.0)],
      "table": {"dontBreakRows": true, "headerRows": 1, "layout": "noBorders", "widths": widths, "body": body}
    };
    return ret;
  }

  @override
  getFormData_(ReportData src)
  {
    var ret = [header];
    var body = [];
    var root = createRoot("entries", body);
    if (showEntries)
    {
      for (int i = 0; i < src.ns.entries.length; i++)
      {
        EntryData entry = src.ns.entries[i];
        var row = [
          {"text": fmtDateTime(entry.time, '??.??.???? ??:?? Uhr'), "colspan": 4},
          {"text": entry.type},
          {"text": fmtNumber(entry.sgv)},
          {"text": fmtNumber(entry.gluc)},
        ];
/*      if(entry.direction != null && entry.direction.toLowerCase() == "none")
      {
        for(dynamic c in row)
          c["color"] = "#f00";
      }*/

        body.add(row);
      }
      ret.add(root);
    }

    if (showTreatments)
    {
      body = [];
      root = createRoot("treatments", body);
      var data = src.ns.treatments;
      for (int i = 0; i < data.length; i++)
      {
        TreatmentData entry = data[i];
        var row = [{"text": fmtDateTime(entry.createdAt, '??.??.???? ??:?? Uhr')}];
        row.add({"text": entry.eventType});
        row.add({"text": "${fmtNumber(entry.adjustedValue(1), 0, false, "")}", "alignment": "right"});
        row.add({"text": entry.duration > 0 ? fmtNumber(entry.duration, 0, false, " ") : " ", "alignment": "right"});
        double carbs = entry.carbs;
        row.add({"text": carbs > 0.0 ? fmtNumber(carbs, 0, false, " ") : " ", "alignment": "right"});
        switch (entry.eventType.toLowerCase())
        {
          case "temp basal":
            row[1]["color"] = "#f00";
            break;
          case "announcement":
          case "note":
            row[1]["text"] = "${row[1]["text"]}\n${entry.notes}";
            break;
        }
        body.add(row);
      }
      ret.add(root);
    }
    return ret;
  }
}