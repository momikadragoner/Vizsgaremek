import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition, query, stagger } from '@angular/animations';
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
     trigger('toggleMenu', [
        state('*', style({
          opacity: '1',
        })),
        state('void', style({
          opacity: '0',
          height: '0'
        })),
        transition(':enter', [
          animate('.5s')
        ]),
        transition(':leave', [
        animate('.5s')
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

  public openView = ""; 

  toggleCategory() {
    if (this.openView != "category") {
      this.openView = "category";
    }
    else{
      this.openView = "";
    }
  }

  toggleNowView(){
    if (this.openView != "now") {
      this.openView = "now";
    }
    else{
      this.openView = "";
    }
  }

  toggleBestView(){
    if (this.openView != "best") {
      this.openView = "best";
    }
    else{
      this.openView = "";
    }
  }

  constructor() { }

  ngOnInit(): void {
  }

}
