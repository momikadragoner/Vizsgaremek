import { Pipe, PipeTransform } from '@angular/core';
import { IconName } from '@fortawesome/fontawesome-svg-core';

@Pipe({name: 'icon'})
export class TagIconPipe implements PipeTransform {
  transform(value: string) {
    let iconName: IconName;
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
        default:
            break;
    }
    iconName = 'hand-paper';
    return iconName;
  }
}