import { Pipe, PipeTransform } from '@angular/core';
import { IconName } from '@fortawesome/fontawesome-svg-core';

@Pipe({ name: 'icon' })
export class TagIconPipe implements PipeTransform {
  transform(value: string, type: string) {
    let iconName: IconName;

    if (type == "tag") {
      switch (value) {
        case "Környezetbarát":
          iconName = 'tree';
          return iconName;
        case "Etikusan beszerzett alapanyagok":
          iconName = 'balance-scale';
          return iconName;
        case "Kézzel készült":
          iconName = 'hand-paper';
          return iconName;
        case "Fenntartható":
          iconName = 'leaf';
          return iconName;
        case "Csomagolás mentes":
          iconName = 'box-open';
          return iconName;
        case "Vegán":
          iconName = 'seedling';
          return iconName;
        case "Vegetáriánus":
          iconName = 'carrot';
          return iconName;
        case "Bio":
          iconName = 'apple-alt';
          return iconName;
        default:
          break;
      }
    } else if (type == "category") {
      switch (value) {
        case "Ékszer":
          iconName = 'gem';
          return iconName;
        case "Tejtermék":
          iconName = 'cheese';
          return iconName;
        default:
          break;
      }
    }
    iconName = 'exclamation-circle';
    return iconName;
  }
}