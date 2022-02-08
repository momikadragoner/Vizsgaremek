import { animate, state, style, transition, trigger } from '@angular/animations';
import { templateJitUrl } from '@angular/compiler';
import { Component, Input, OnInit, Output } from '@angular/core';
import { EventEmitter } from '@angular/core';
import { faStar, faTimes } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'modal-window',
  templateUrl: './modal.component.html',
  styleUrls: ['./modal.component.scss'],
  animations: [
    trigger('openModal', [
       state('*', style({
         opacity: '1',
        })),
        state('void', style({
          opacity: '0',
       })),
       transition(':enter', [
         animate('.2s ease-out')
       ]),
       transition(':leave', [
       animate('.2s ease-out')
     ]),  
    ]),
 ]

})
export class ModalComponent implements OnInit {

  faClose = faTimes;

  @Input() modalVisible = false;
  @Input() allowClose = true;
  @Input() title = "";
  @Output() modalVisibleChange = new EventEmitter<boolean>();


  addModalVisible(value:boolean){
    this.modalVisibleChange.emit(value);
  }

  toggleModal(){
    if(this.allowClose){
      this.modalVisible = !this.modalVisible;
      this.addModalVisible(this.modalVisible);
    }
  }

  constructor() { 
  }

  ngOnInit(): void {
  }

}
