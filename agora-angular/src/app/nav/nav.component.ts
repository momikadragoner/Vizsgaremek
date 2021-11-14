import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition } from '@angular/animations';
import { faCarrot } from '@fortawesome/free-solid-svg-icons';
import { faAppleAlt } from '@fortawesome/free-solid-svg-icons';
import { faBreadSlice } from '@fortawesome/free-solid-svg-icons';
import { faCheese } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss'],
  animations: [
    trigger('toggleCategory', [
      state('*', style({
        opacity: '1'
      })),
      state('void', style({
        opacity: '0',
        height: '0'
      })),
      transition(':enter', [ 
        animate('.2s ease-out')
      ]),
      transition(':leave', [
        animate('.2s ease-in')
      ])
    ])
  ]
})
export class NavComponent implements OnInit {
  
  faCarrot = faCarrot;
  faBread = faBreadSlice;
  faApple = faAppleAlt;
  faCheese = faCheese;

  public isOpen = false;

  toggleCategory() {
    this.isOpen = !this.isOpen;
  }

  constructor() { }

  ngOnInit(): void {
  }

}
