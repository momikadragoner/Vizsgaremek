import { Component, OnInit } from '@angular/core';
import { faSearch } from '@fortawesome/free-solid-svg-icons';
import { faChevronDown } from '@fortawesome/free-solid-svg-icons';
import { Product, productsClass} from '../product-detail/test-data';

@Component({
  selector: 'app-front-page',
  templateUrl: './front-page.component.html',
  styleUrls: ['./front-page.component.scss']
})
export class FrontPageComponent implements OnInit {

  faSearch = faSearch;
  faChevronDown = faChevronDown;

  public products = productsClass;

  constructor() {}

  ngOnInit(): void {
  }

}
