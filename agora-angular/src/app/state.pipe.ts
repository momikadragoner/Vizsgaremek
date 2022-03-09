import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'state' })
export class StatePipe implements PipeTransform {
    transform(value: string) {
        switch (value) {
            case "Ordered":
                return 'Rendelés fogadva';
            case "Packaging":
                return 'Összekészítés alatt';
            case "Delivery in progress":
                return 'Szállítás folyamatban';
            case "Unavailable":
                return 'Nem elérhető';
            case "Arrived":
                return 'Megérkezett';
            default:
                break;
        }
        return "";
    }
}