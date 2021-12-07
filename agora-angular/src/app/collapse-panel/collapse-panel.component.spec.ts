import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CollapsePanelComponent } from './collapse-panel.component';

describe('CollapsePanelComponent', () => {
  let component: CollapsePanelComponent;
  let fixture: ComponentFixture<CollapsePanelComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CollapsePanelComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CollapsePanelComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
