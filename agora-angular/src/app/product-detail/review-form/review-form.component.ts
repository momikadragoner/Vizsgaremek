import { animate, style, transition, trigger } from '@angular/animations';
import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { FontAwesomeModule, FaIconLibrary } from '@fortawesome/angular-fontawesome'
import { faStar as farStar } from '@fortawesome/free-regular-svg-icons'
import { faStar as fasStar} from '@fortawesome/free-solid-svg-icons'
import { Review } from 'src/app/services/review.service';

@Component({
  selector: 'review-form',
  templateUrl: './review-form.component.html',
  styleUrls: ['./review-form.component.scss'],
  animations: [
    trigger('visibilityChange',[
      transition(':leave', [
        style({ opacity: 1}),
        animate('0.2s',
          style({ opacity: 0, height: 0}))
      ]),
      transition(':enter', [
        style({ opacity: 0, height: 0}),
        animate('0.2s',
          style({ opacity: 1}))
      ])
    ])
  ]
})
export class ReviewFormComponent implements OnInit {

  farStar = farStar;
  fasStar = fasStar;

  @Output() modalState = new EventEmitter<boolean>();
  rating:number = -1;

  constructor(
    library:FaIconLibrary, 
    private fb: FormBuilder,
  ){
    library.addIcons(fasStar, farStar);
  }

  reviewForm = this.fb.group({
    title: ['', Validators.required],
    review: ['', Validators.required]
  });

  solidStars(i:number){
    this.rating = i;
  }

  back($event:any){
    $event.preventDefault();
    this.modalState.emit(false);
  }

  onSubmit(){
    let form = this.reviewForm.value;
    let newReview:Review = new Review()
    newReview.content = form.review;
    newReview.title = form.title;
    newReview.rating = this.rating;
    newReview.points = 0;
  }

  ngOnInit(): void {
  }

}
