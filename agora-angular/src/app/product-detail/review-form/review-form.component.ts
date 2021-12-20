import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FontAwesomeModule, FaIconLibrary } from '@fortawesome/angular-fontawesome'
import { faStar as farStar } from '@fortawesome/free-regular-svg-icons'
import { faStar as fasStar} from '@fortawesome/free-solid-svg-icons'

@Component({
  selector: 'review-form',
  templateUrl: './review-form.component.html',
  styleUrls: ['./review-form.component.scss']
})
export class ReviewFormComponent implements OnInit {

  farStar = farStar;
  fasStar = fasStar;

  @Output() modalState = new EventEmitter<boolean>();
  rating:number = 0;

  constructor(library:FaIconLibrary){
    library.addIcons(fasStar, farStar);
  }

  solidStars(i:number){
    this.rating = i;
  }

  back($event:any){
    $event.preventDefault();
    this.modalState.emit(false);
  }

  ngOnInit(): void {
  }

}
