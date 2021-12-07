import { animate, state, style, transition, trigger } from '@angular/animations';
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  animations: [
    trigger('routeAnimations', [
       state('*', style({
         opacity: '1',
       })),
       state('void', style({
         opacity: '0',
       })),
       transition(':enter', [
         animate('.4s')
       ]),
       transition(':leave', [
         animate('.4s')
       ]),  
    ]),
 ]
})
export class AppComponent {
  
  title = 'agora-angular';

  prepareRoute(outlet: RouterOutlet) {
    return outlet?.activatedRouteData?.['animation'];
  }

}