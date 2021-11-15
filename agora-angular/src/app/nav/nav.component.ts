import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition } from '@angular/animations';
import { faCarrot } from '@fortawesome/free-solid-svg-icons';
import { faAppleAlt } from '@fortawesome/free-solid-svg-icons';
import { faBreadSlice } from '@fortawesome/free-solid-svg-icons';
import { faCheese } from '@fortawesome/free-solid-svg-icons';
import { faPalette } from '@fortawesome/free-solid-svg-icons';
import { faGem } from '@fortawesome/free-solid-svg-icons';
import { faTshirt } from '@fortawesome/free-solid-svg-icons';
import { faGlassMartiniAlt } from '@fortawesome/free-solid-svg-icons';

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
      ]),
    ]),
    trigger('clickNowView', [
      state('nowOpen', style({
        backgroundColor: 'yellow',
        borderRadius: '1rem'
      })),
      state('nowClosed',style({

      })),
      transition('nowClosed => nowOpen', [
        animate('1s')
      ]),
    ]),
  ]
})
export class NavComponent implements OnInit {
  
  faCarrot = faCarrot;
  faBread = faBreadSlice;
  faApple = faAppleAlt;
  faCheese = faCheese;
  faPalette = faPalette;
  faGem = faGem;
  faTshirt = faTshirt;
  faGlassMartiniAlt = faGlassMartiniAlt;

  public isOpen = false;
  public isNowOpen = false;

  toggleCategory() {
    this.isOpen = !this.isOpen;
    this.isNowOpen = false;
  }

  toggleNowView(){
    this.isNowOpen = !this.isNowOpen;
    this.isOpen = false;
  }

  constructor() { }

  ngOnInit(): void {
  }

}
