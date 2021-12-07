import { Component, Input, OnInit } from '@angular/core';
import { animate, state, style, transition, trigger } from '@angular/animations';
import { faPlus, faMinus } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'collapse-panel',
  templateUrl: './collapse-panel.component.html',
  styleUrls: ['./collapse-panel.component.scss'],
  animations: [
    trigger('togglePanel', [
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
export class CollapsePanelComponent implements OnInit {

  @Input() public title = "";

  constructor() { }

  faPlus = faPlus;
  faMinus = faMinus;
  
  panelOpen:boolean = false;

  togglePanel(){
    this.panelOpen = !this.panelOpen;
  }

  ngOnInit(): void {
  }

}